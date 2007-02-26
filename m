From: Ralf Baechle <ralf@linux-mips.org>
Subject: [NET] sgiseeq: Don't include unnecessary headerfiles.
Date: Mon, 26 Feb 2007 01:50:34 +0000
Message-ID: <20070226015034.GA24954@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:48820 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750994AbXBZBva (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Feb 2007 20:51:30 -0500
Received: from localhost.localdomain ([127.0.0.1]:58566 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S20039013AbXBZBv2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Feb 2007 01:51:28 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index a833e7f..52ed522 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -12,26 +12,15 @@
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/interrupt.h>
-#include <linux/ioport.h>
-#include <linux/socket.h>
-#include <linux/in.h>
-#include <linux/route.h>
 #include <linux/slab.h>
 #include <linux/string.h>
 #include <linux/delay.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
-#include <linux/bitops.h>
 
-#include <asm/byteorder.h>
-#include <asm/io.h>
-#include <asm/system.h>
-#include <asm/page.h>
-#include <asm/pgtable.h>
 #include <asm/sgi/hpc3.h>
 #include <asm/sgi/ip22.h>
-#include <asm/sgialib.h>
 
 #include "sgiseeq.h"
 
