From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/4] gigaset: small documentation improvement
Date: Tue, 23 Feb 2010 00:08:51 +0100 (CET)
Message-ID: <20100221-patch-gigaset-01.tilman@imap.cc>
References: <20100221-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100221-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/4] gigaset: small documentation improvement

Clarify the non-support by isdnlog, and propose a better standard
debug mask.

Impact: Documentation
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 Documentation/isdn/README.gigaset |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/Documentation/isdn/README.gigaset b/Documentation/isdn/README.gigaset
index 794941f..e472df8 100644
--- a/Documentation/isdn/README.gigaset
+++ b/Documentation/isdn/README.gigaset
@@ -292,10 +292,10 @@ GigaSet 307x Device Driver
         to /etc/modprobe.d/gigaset, /etc/modprobe.conf.local or a similar file.
 
      Problem:
-        Your isdn script aborts with a message about isdnlog.
+        The isdnlog program emits error messages or just doesn't work.
      Solution:
-        Try deactivating (or commenting out) isdnlog. This driver does not
-        support it.
+        Isdnlog supports only the HiSax driver. Do not attempt to use it with
+	other drivers such as Gigaset.
 
      Problem:
         You have two or more DECT data adapters (M101/M105) and only the
@@ -321,8 +321,8 @@ GigaSet 307x Device Driver
      writing an appropriate value to /sys/module/gigaset/parameters/debug, e.g.
         echo 0 > /sys/module/gigaset/parameters/debug
      switches off debugging output completely,
-        echo 0x10a020 > /sys/module/gigaset/parameters/debug
-     enables the standard set of debugging output messages. These values are
+        echo 0x302020 > /sys/module/gigaset/parameters/debug
+     enables a reasonable set of debugging output messages. These values are
      bit patterns where every bit controls a certain type of debugging output.
      See the constants DEBUG_* in the source file gigaset.h for details.
 
-- 
1.6.5.3.298.g39add
