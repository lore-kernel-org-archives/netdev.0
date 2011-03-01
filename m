From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [patch net-next-2.6] bonding: remove skb_share_check in
 handle_frame
Date: Tue, 1 Mar 2011 10:29:07 +0100
Message-ID: <20110301092907.GG2855@psychotron.redhat.com>
References: <20110301062250.GB2855@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com, andy@greyhouse.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754342Ab1CAJ3N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 04:29:13 -0500
Content-Disposition: inline
In-Reply-To: <20110301062250.GB2855@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unapplicable, sorry (wrong branch :(). Here's corrected patch:

Subject: [PATCH net-next-2.6 v2] bonding: remove skb_share_check in handle_frame

No need to do share check here.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 584f97b..367ea60 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1498,9 +1498,6 @@ static struct sk_buff *bond_handle_frame(struct sk_buff *skb)
 	struct net_device *slave_dev;
 	struct net_device *bond_dev;
 
-	skb = skb_share_check(skb, GFP_ATOMIC);
-	if (unlikely(!skb))
-		return NULL;
 	slave_dev = skb->dev;
 	bond_dev = ACCESS_ONCE(slave_dev->master);
 	if (unlikely(!bond_dev))
-- 
1.7.3.4

	
