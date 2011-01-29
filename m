From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH] caif: bugfix - add caif headers for userspace usage.
Date: Sun, 30 Jan 2011 00:10:37 +0100
Message-ID: <1296342637-7039-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from thalia-smout.broadpark.no ([80.202.8.21]:45710 "EHLO
	thalia-smout.broadpark.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752416Ab1A3AKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 19:10:52 -0500
Received: from terra-smin.broadpark.no ([80.202.8.13])
 by thalia-smout.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LFT00AJL4E21340@thalia-smout.broadpark.no> for
 netdev@vger.kernel.org; Sun, 30 Jan 2011 00:10:50 +0100 (CET)
Received: from localhost.localdomain ([80.203.143.228])
 by terra-smin.broadpark.no
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0LFT002JS4E1MX00@terra-smin.broadpark.no> for
 netdev@vger.kernel.org; Sun, 30 Jan 2011 00:10:50 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add caif_socket.h and if_caif.h to the kernel header files
exported for use by userspace.

Signed-off-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
---
Hi Dave,

This patch applies cleanly on net-2.6 and net-next-2.6
Please apply as appropriate.

Thanks,
Sjur Br=C3=A6ndeland

 include/linux/Kbuild      |    1 +
 include/linux/caif/Kbuild |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/caif/Kbuild

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 2296d8b..b0ada6f 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -1,5 +1,6 @@
 header-y +=3D byteorder/
 header-y +=3D can/
+header-y +=3D caif/
 header-y +=3D dvb/
 header-y +=3D hdlc/
 header-y +=3D isdn/
diff --git a/include/linux/caif/Kbuild b/include/linux/caif/Kbuild
new file mode 100644
index 0000000..a9cf250
--- /dev/null
+++ b/include/linux/caif/Kbuild
@@ -0,0 +1,2 @@
+header-y +=3D caif_socket.h
+header-y +=3D if_caif.h
--=20
1.7.0.4

