From: Hannes Eder <hannes@hanneseder.net>
Subject: [PATCH 35/43] drivers/net/wan: fix warning: format not a string
	literal and no ...
Date: Sat, 14 Feb 2009 22:48:07 +0100
Message-ID: <20090214214755.24377.57742.stgit@vmbox.hanneseder.net>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f167.google.com ([209.85.218.167]:33361 "EHLO
	mail-bw0-f167.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355AbZBNVsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:48:11 -0500
In-Reply-To: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Impact: Use 'static const char[]' instead of 'static char[]'.

Fix this compilation warnings:
  drivers/net/wan/lapbether.c: In function 'lapbeth_init_driver':
  drivers/net/wan/lapbether.c:441: warning: format not a string literal and no format arguments
  drivers/net/wan/z85230.c: In function 'z85230_init_driver':
  drivers/net/wan/z85230.c:1782: warning: format not a string literal and no format arguments

Signed-off-by: Hannes Eder <hannes@hanneseder.net>
---
 drivers/net/wan/lapbether.c |    3 ++-
 drivers/net/wan/z85230.c    |    3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wan/lapbether.c b/drivers/net/wan/lapbether.c
index da9dcf5..06beba4 100644
--- a/drivers/net/wan/lapbether.c
+++ b/drivers/net/wan/lapbether.c
@@ -430,7 +430,8 @@ static struct notifier_block lapbeth_dev_notifier = {
 	.notifier_call = lapbeth_device_event,
 };
 
-static char banner[] __initdata = KERN_INFO "LAPB Ethernet driver version 0.02\n";
+static const char banner[] __initdata =
+	KERN_INFO "LAPB Ethernet driver version 0.02\n";
 
 static int __init lapbeth_init_driver(void)
 {
diff --git a/drivers/net/wan/z85230.c b/drivers/net/wan/z85230.c
index 3d00971..ad4e79c 100644
--- a/drivers/net/wan/z85230.c
+++ b/drivers/net/wan/z85230.c
@@ -1775,7 +1775,8 @@ EXPORT_SYMBOL(z8530_queue_xmit);
 /*
  *	Module support
  */
-static char banner[] __initdata = KERN_INFO "Generic Z85C30/Z85230 interface driver v0.02\n";
+static const char banner[] __initdata =
+	KERN_INFO "Generic Z85C30/Z85230 interface driver v0.02\n";
 
 static int __init z85230_init_driver(void)
 {

