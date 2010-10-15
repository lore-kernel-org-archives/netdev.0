From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] bonding: make
 bond_resend_igmp_join_requests_delayed static
Date: Fri, 15 Oct 2010 14:02:56 -0700
Message-ID: <20101015140256.4192fd34@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35395 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756407Ab0JOVC7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 17:02:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2010-10-15 13:52:01.747192520 -0700
+++ b/drivers/net/bonding/bond_main.c	2010-10-15 13:52:39.004286643 -0700
@@ -914,7 +914,7 @@ static void bond_resend_igmp_join_reques
 	read_unlock(&bond->lock);
 }
 
-void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
+static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
 {
 	struct bonding *bond = container_of(work, struct bonding,
 							mcast_work.work);
