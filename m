From: Don Fry <pcnet32@verizon.net>
Subject: [PATCH 2.6.24] pcnet32:  Use print_mac
Date: Fri, 08 Feb 2008 07:29:38 -0800
Message-ID: <1202484576.10535.4.camel@new-host.home>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms173001pub.verizon.net ([206.46.173.1]:32855 "EHLO
	vms173001pub.verizon.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756724AbYBHQIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 11:08:42 -0500
Received: from [192.168.1.3] ([96.225.193.28]) by vms173001.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-6.01 (built Apr  3 2006))
 with ESMTPA id <0JVX00MUKG7TVMK4@vms173001.mailsrvcs.net> for
 netdev@vger.kernel.org; Fri, 08 Feb 2008 09:55:06 -0600 (CST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
Acked-by:  Don Fry <pcnet32@verizon.net>
---
Originally sent by Joe Dec 14, 2007
Tested by Don on amd_64

--- linux-2.6.24-git13/drivers/net/orig.pcnet32.c	2008-02-04 10:05:48.000000000 -0800
+++ linux-2.6.24-git18/drivers/net/pcnet32.c	2008-02-04 10:59:08.000000000 -0800
@@ -1774,8 +1774,8 @@ pcnet32_probe1(unsigned long ioaddr, int
 		memset(dev->dev_addr, 0, sizeof(dev->dev_addr));
 
 	if (pcnet32_debug & NETIF_MSG_PROBE) {
-		for (i = 0; i < 6; i++)
-			printk(" %2.2x", dev->dev_addr[i]);
+		DECLARE_MAC_BUF(mac);
+		printk(" %s", print_mac(mac, dev->dev_addr));
 
 		/* Version 0x2623 and 0x2624 */
 		if (((chip_version + 1) & 0xfffe) == 0x2624) {


