From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH [iputils] 3/6] start gitignore files
Date: Fri, 25 Jan 2013 00:24:12 -0500
Message-ID: <1359091455-25380-3-git-send-email-vapier@gentoo.org>
References: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:38486 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751305Ab3AYFYO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 00:24:14 -0500
In-Reply-To: <1359091455-25380-1-git-send-email-vapier@gentoo.org>
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
1.8.0.2
