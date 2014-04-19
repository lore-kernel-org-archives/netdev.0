From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH [iputils] 1/5] start gitignore files
Date: Sat, 19 Apr 2014 10:43:13 -0400
Message-ID: <1397918597-8680-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org,
	David Heidelberger <david.heidelberger@ixit.cz>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:48257 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751065AbaDSOnR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Apr 2014 10:43:17 -0400
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
1.9.2
