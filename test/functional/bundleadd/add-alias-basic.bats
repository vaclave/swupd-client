#!/usr/bin/env bats

# Author: <author name>
# Email: <author email>

load "../testlib"

global_setup() {

	create_test_environment "$TEST_NAME"
	create_bundle -n test-bundle1 -f /foo/test-file1 "$TEST_NAME"
	create_bundle -n alias-bundle1 -f /foo/alias-file1 "$TEST_NAME"
	create_bundle -n alias-bundle2 -f /foo/alias-file2 "$TEST_NAME"
	create_bundle -n alias-bundle3 -f /foo/alias-file3 "$TEST_NAME"
}

test_setup() {

        return

}

test_teardown() {

	remove_bundle -L "$TEST_NAME"/web-dir/10/Manifest.test-bundle1
	remove_bundle -L "$TEST_NAME"/web-dir/10/Manifest.alias-bundle1
	remove_bundle -L "$TEST_NAME"/web-dir/10/Manifest.alias-bundle2
	remove_bundle -L "$TEST_NAME"/web-dir/10/Manifest.alias-bundle3
        run sudo sh -c "rm -rf "$TARGETDIR"/usr/share/defaults/swupd/alias.d/"
        run sudo sh -c "rm -rf "$TARGETDIR"/etc/swupd/alias.d/"
	clean_state_dir "$TEST_NAME"

}

global_teardown() {

	destroy_test_environment "$TEST_NAME"

}

@test "ADD032: Add bundle without alias" {

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS test-bundle1"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 1 bundle
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/test-file1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/test-bundle1

}

@test "ADD033: Add bundle with system alias" {

        run sudo sh -c "mkdir -p $TARGETDIR/usr/share/defaults/swupd/alias.d/"
        run sudo sh -c "echo -e 'alias1\talias-bundle1' > $TARGETDIR/usr/share/defaults/swupd/alias.d/a1"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias1"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 1 bundle
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1

}

@test "ADD034: Add bundle with user alias" {

        run sudo sh -c "mkdir -p $TARGETDIR/etc/swupd/alias.d/"
        run sudo sh -c "echo -e 'alias1\talias-bundle1' > $TARGETDIR/etc/swupd/alias.d/a1"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias1"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 1 bundle
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1

}

@test "ADD035: Add bundles with alias (single file)" {

        run sudo sh -c "mkdir -p $TARGETDIR/etc/swupd/alias.d/"
        run sudo sh -c "echo -e 'alias1\talias-bundle1\talias-bundle2' > $TARGETDIR/etc/swupd/alias.d/a1"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias1"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 2 bundles
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/foo/alias-file2
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle2

}

@test "ADD036: Add bundles with aliases (single file, multi-line)" {

        run sudo sh -c "mkdir -p $TARGETDIR/etc/swupd/alias.d/"
        run sudo sh -c "echo -e 'alias1\talias-bundle1\nalias2\talias-bundle2' > $TARGETDIR/etc/swupd/alias.d/a1"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias1 alias2"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 2 bundles
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/foo/alias-file2
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle2

}

@test "ADD037: Add bundles with aliases (multiple files)" {

        run sudo sh -c "mkdir -p $TARGETDIR/usr/share/defaults/swupd/alias.d/"
        run sudo sh -c "mkdir -p $TARGETDIR/etc/swupd/alias.d/"
        run sudo sh -c "echo -e 'alias1\talias-bundle1' > $TARGETDIR/etc/swupd/alias.d/a1"
        run sudo sh -c "echo -e 'alias2\talias-bundle2' > $TARGETDIR/usr/share/defaults/swupd/alias.d/a2"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias1 alias2"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 2 bundles
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/foo/alias-file2
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle2

}

@test "ADD038: Add bundle with alias (user mask)" {

        run sudo sh -c "mkdir -p $TARGETDIR/usr/share/defaults/swupd/alias.d/"
        run sudo sh -c "mkdir -p $TARGETDIR/etc/swupd/alias.d/"
        run sudo sh -c "ln -s /dev/null $TARGETDIR/etc/swupd/alias.d/a1"
        run sudo sh -c "echo -e 'alias-bundle1\talias-bundle2' > $TARGETDIR/usr/share/defaults/swupd/alias.d/a1"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias-bundle1"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 1 bundle
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1

}

@test "ADD039: Add bundle with alias (user override for different bundle)" {

        run sudo sh -c "mkdir -p $TARGETDIR/usr/share/defaults/swupd/alias.d/"
        run sudo sh -c "mkdir -p $TARGETDIR/etc/swupd/alias.d/"
        run sudo sh -c "echo -e 'alias1\talias-bundle1' > $TARGETDIR/etc/swupd/alias.d/a1"
        run sudo sh -c "echo -e 'test-bundle1\talias-bundle2' > $TARGETDIR/usr/share/defaults/swupd/alias.d/a1"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias1 test-bundle1"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 2 bundles
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/foo/test-file1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/test-bundle1

}

@test "ADD040: Add bundle with alias (user priority for different bundle)" {

        run sudo sh -c "mkdir -p $TARGETDIR/usr/share/defaults/swupd/alias.d/"
        run sudo sh -c "mkdir -p $TARGETDIR/etc/swupd/alias.d/"
        run sudo sh -c "echo -e 'alias1\talias-bundle1' > $TARGETDIR/etc/swupd/alias.d/b1"
        run sudo sh -c "echo -e 'alias1\talias-bundle2' > $TARGETDIR/usr/share/defaults/swupd/alias.d/a1"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias1"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 1 bundle
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1

}

@test "ADD041: Add bundle with alias (name priority for different bundle)" {

        run sudo sh -c "mkdir -p $TARGETDIR/etc/swupd/alias.d/"
        run sudo sh -c "echo -e 'alias1\talias-bundle1' > $TARGETDIR/etc/swupd/alias.d/a1"
        run sudo sh -c "echo -e 'alias1\talias-bundle2' > $TARGETDIR/etc/swupd/alias.d/b1"

	run sudo sh -c "$SWUPD bundle-add $SWUPD_OPTS alias1"

	assert_status_is 0
	expected_output=$(cat <<-EOM
		Starting download of remaining update content. This may take a while...
		.
		Finishing download of update content...
		Installing bundle(s) files...
		.
		Calling post-update helper scripts.
		Successfully installed 1 bundle
	EOM
	)
	assert_is_output --identical "$expected_output"
	assert_file_exists "$TARGETDIR"/foo/alias-file1
	assert_file_exists "$TARGETDIR"/usr/share/clear/bundles/alias-bundle1

}
