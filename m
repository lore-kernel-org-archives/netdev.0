From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH 3/3] 8390.h: remove net_device_stats
Date: Wed, 07 May 2008 02:20:45 +0300
Message-ID: <4820E7CD.6050009@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020005060703000201070308"
Cc: becker@scyld.com, dahinds@users.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:52285 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753608AbYEFXaF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 19:30:05 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JtWbi-0000qa-LU
	for netdev@vger.kernel.org; Tue, 06 May 2008 23:30:02 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 23:30:02 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 06 May 2008 23:30:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020005060703000201070308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Remove no longer used net_device_stats.
Should be applied to mainline only after applying previous two patches.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------020005060703000201070308
Content-Type: text/x-patch;
 name="8390_h_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="8390_h_netstats.patch"

diff --git a/drivers/net/8390.h b/drivers/net/8390.h
index 04ddec0..cf020d4 100644
--- a/drivers/net/8390.h
+++ b/drivers/net/8390.h
@@ -69,7 +69,6 @@ struct ei_device {
 	unsigned char reg0;		/* Register '0' in a WD8013 */
 	unsigned char reg5;		/* Register '5' in a WD8013 */
 	unsigned char saved_irq;	/* Original dev->irq value. */
-	struct net_device_stats stat;	/* The new statistics table. */
 	u32 *reg_offset;		/* Register mapping table */
 	spinlock_t page_lock;		/* Page register locks */
 	unsigned long priv;		/* Private field to store bus IDs etc. */

--------------020005060703000201070308--

