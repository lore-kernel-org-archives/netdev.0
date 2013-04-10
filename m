From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] bnx2: make cnic_probe static
Date: Wed, 10 Apr 2013 13:53:40 -0700
Message-ID: <20130410135340.06f88645@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:51367 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763054Ab3DJUyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 16:54:01 -0400
Received: by mail-pa0-f53.google.com with SMTP id bh4so513462pad.26
        for <netdev@vger.kernel.org>; Wed, 10 Apr 2013 13:54:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/broadcom/bnx2.c	2013-04-10 09:10:46.167617920 -0700
+++ b/drivers/net/ethernet/broadcom/bnx2.c	2013-04-10 13:18:43.946608448 -0700
@@ -416,7 +416,7 @@ static int bnx2_unregister_cnic(struct n
 	return 0;
 }
 
-struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
+static struct cnic_eth_dev *bnx2_cnic_probe(struct net_device *dev)
 {
 	struct bnx2 *bp = netdev_priv(dev);
 	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
