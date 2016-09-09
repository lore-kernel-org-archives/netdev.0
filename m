From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 3/9] selftests: move .gitignore from Documentation/filesystems
Date: Fri,  9 Sep 2016 16:22:44 -0600
Message-ID: <67cdfc151b5771b6628eeaf154f1d5d712423abe.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        linux-kselftest@vger.kernel.org
To: corbet@lwn.net, richardcochran@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
In-Reply-To: <cover.1473458697.git.shuahkh@osg.samsung.com>
References: <cover.1473458697.git.shuahkh@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Move .gitignore for dnotify_test from Documentation/filesystems to
selftests/filesystems.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 Documentation/filesystems/.gitignore           | 1 -
 tools/testing/selftests/filesystems/.gitignore | 1 +
 2 files changed, 1 insertion(+), 1 deletion(-)
 delete mode 100644 Documentation/filesystems/.gitignore
 create mode 100644 tools/testing/selftests/filesystems/.gitignore

diff --git a/Documentation/filesystems/.gitignore b/Documentation/filesystems/.gitignore
deleted file mode 100644
index 31d6e42..0000000
--- a/Documentation/filesystems/.gitignore
+++ /dev/null
@@ -1 +0,0 @@
-dnotify_test
diff --git a/tools/testing/selftests/filesystems/.gitignore b/tools/testing/selftests/filesystems/.gitignore
new file mode 100644
index 0000000..31d6e42
--- /dev/null
+++ b/tools/testing/selftests/filesystems/.gitignore
@@ -0,0 +1 @@
+dnotify_test
-- 
2.7.4
