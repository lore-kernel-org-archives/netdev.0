From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH] bonding: Remove debug printk
Date: Tue, 14 Apr 2009 16:51:49 -0700
Message-ID: <8409.1239753109@death.nxdomain.ibm.com>
References: <1225849876-8930-1-git-send-email-fubar@us.ibm.com> <1225849876-8930-2-git-send-email-fubar@us.ibm.com> <1225849876-8930-3-git-send-email-fubar@us.ibm.com> <49E518F8.3030109@siriusit.co.uk>
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>,
	"David S. Miller" <davem@davemloft.net>
To: Duncan Gibb <duncan.gibb@siriusit.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:43594 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752011AbZDNXvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2009 19:51:44 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3ENmUmr019186
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 19:48:30 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3ENphsE195566
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 19:51:43 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3ENphbw013881
	for <netdev@vger.kernel.org>; Tue, 14 Apr 2009 19:51:43 -0400
In-reply-to: <49E518F8.3030109@siriusit.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Remove debug printk I accidently left in as part of commit:

commit 6146b1a4da98377e4abddc91ba5856bef8f23f1e
Author: Jay Vosburgh <fubar@us.ibm.com>
Date:   Tue Nov 4 17:51:15 2008 -0800

    bonding: Fix ALB mode to balance traffic on VLANs

	Reported by Duncan Gibb <duncan.gibb@siriusit.co.uk>

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>



diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 8dc6fbb..553a899 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -370,8 +370,6 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
-		printk("rar: update orig %s bond_dev %s\n", orig_dev->name,
-		       bond_dev->name);
 		bond = netdev_priv(bond_dev);
 		rlb_update_entry_from_arp(bond, arp);
 		pr_debug("Server received an ARP Reply from client\n");
