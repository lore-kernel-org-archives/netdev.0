From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iputils 1/6] start gitignore files
Date: Tue, 31 May 2016 23:48:20 -0400
Message-ID: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58820 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754676AbcFADs3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 23:48:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 .gitignore     | 22 ++++++++++++++++++++++
 doc/.gitignore |  2 ++
 2 files changed, 24 insertions(+)
 create mode 100644 .gitignore
 create mode 100644 doc/.gitignore

diff --git a/.gitignore b/.gitignore
new file mode 100644
index 0000000..30ed00c
--- /dev/null
+++ b/.gitignore
@@ -0,0 +1,22 @@
+*~
+*.o
+
+*.diff
+*.orig
+*.patch
+*.rej
+
+core
+.gdb_history
+.gdbinit
+
+/arping
+/clockdiff
+/ping
+/ping6
+/rarpd
+/rdisc
+/tftpd
+/tracepath
+/tracepath6
+/traceroute6
diff --git a/doc/.gitignore b/doc/.gitignore
new file mode 100644
index 0000000..085639f
--- /dev/null
+++ b/doc/.gitignore
@@ -0,0 +1,2 @@
+*.html
+*.8
-- 
2.8.2
