From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 4/9] cxgb4: set dev_id to the port number
Date: Wed, 16 Jun 2010 15:01:11 -0700
Message-ID: <1276725676-31514-5-git-send-email-dm@chelsio.com>
References: <1276725676-31514-1-git-send-email-dm@chelsio.com>
 <1276725676-31514-2-git-send-email-dm@chelsio.com>
 <1276725676-31514-3-git-send-email-dm@chelsio.com>
 <1276725676-31514-4-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:2208 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759312Ab0FPWBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:01:17 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5GM1IBC032124
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:18 -0700
In-Reply-To: <1276725676-31514-4-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/t4_hw.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb4/t4_hw.c b/drivers/net/cxgb4/t4_hw.c
index 0c8a84a..4c956fb 100644
--- a/drivers/net/cxgb4/t4_hw.c
+++ b/drivers/net/cxgb4/t4_hw.c
@@ -3162,6 +3162,7 @@ int __devinit t4_port_init(struct adapter *adap, int mbox, int pf, int vf)
 		p->rss_size = rss_size;
 		memcpy(adap->port[i]->dev_addr, addr, ETH_ALEN);
 		memcpy(adap->port[i]->perm_addr, addr, ETH_ALEN);
+		adap->port[i]->dev_id = j;
 
 		ret = ntohl(c.u.info.lstatus_to_modtype);
 		p->mdio_addr = (ret & FW_PORT_CMD_MDIOCAP) ?
-- 
1.5.4

