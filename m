From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/4] myri10ge: update wcfifo and intr_coal_delay default values
Date: Wed, 21 Mar 2007 19:45:56 +0100
Message-ID: <46017D64.1070201@myri.com>
References: <45FDA22E.1070805@myri.com> <46017CB8.3060807@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:2027 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933620AbXCUSry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Mar 2007 14:47:54 -0400
In-Reply-To: <46017CB8.3060807@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Update the default value of 2 module parameters:
* wcfifo disabled
* intr_coal_delay 75us

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-18 21:14:12.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-18 21:14:21.000000000 +0100
@@ -234,7 +234,7 @@
 module_param(myri10ge_msi, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_msi, "Enable Message Signalled Interrupts\n");
 
-static int myri10ge_intr_coal_delay = 25;
+static int myri10ge_intr_coal_delay = 75;
 module_param(myri10ge_intr_coal_delay, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_intr_coal_delay, "Interrupt coalescing delay\n");
 
@@ -279,7 +279,7 @@
 module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
 
-static int myri10ge_wcfifo = 1;
+static int myri10ge_wcfifo = 0;
 module_param(myri10ge_wcfifo, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_wcfifo, "Enable WC Fifo when WC is enabled\n");
 


