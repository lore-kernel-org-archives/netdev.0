From: Scott Feldman <sfeldma@pobox.com>
Subject: [PATCH] pktgen: clear error count before each run
Date: Tue, 30 Nov 2004 12:24:16 -0800
Message-ID: <1101846256.4663.31.camel@sfeldma-mobl.dsl-verizon.net>
Reply-To: sfeldma@pobox.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Scott Feldman <sfeldma@pobox.com>

--- linux-2.6.10-rc2/net/core/pktgen.c.orig	2004-11-30 12:16:35.914025424 -0800
+++ linux-2.6.10-rc2/net/core/pktgen.c	2004-11-30 12:18:36.588680088 -0800
@@ -647,6 +647,7 @@
 	info->do_run_run = 1; /* Cranke yeself! */
 	info->idle_acc = 0;
 	info->sofar = 0;
+	info->errors = 0;
 	lcount = info->count;
 
 
