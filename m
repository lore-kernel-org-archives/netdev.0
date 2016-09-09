From: Shuah Khan <shuahkh@osg.samsung.com>
Subject: [PATCH 2/9] selftests: update filesystems Makefile to work under selftests
Date: Fri,  9 Sep 2016 16:22:43 -0600
Message-ID: <239195aa67e72b7eb971cdacfc9e338de912524e.1473458697.git.shuahkh@osg.samsung.com>
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

Update to work under selftests. dnotify_test will not be run as part of
selftests suite and will not included in install targets. It can be built
separately for now.

Signed-off-by: Shuah Khan <shuahkh@osg.samsung.com>
---
 tools/testing/selftests/filesystems/Makefile | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/tools/testing/selftests/filesystems/Makefile b/tools/testing/selftests/filesystems/Makefile
index 883010c..f1dce5c 100644
--- a/tools/testing/selftests/filesystems/Makefile
+++ b/tools/testing/selftests/filesystems/Makefile
@@ -1,5 +1,7 @@
-# List of programs to build
-hostprogs-y := dnotify_test
+TEST_PROGS := dnotify_test
+all: $(TEST_PROGS)
 
-# Tell kbuild to always build the programs
-always := $(hostprogs-y)
+include ../lib.mk
+
+clean:
+	rm -fr dnotify_test
-- 
2.7.4
