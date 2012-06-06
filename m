From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/7] be2net: remove unnecessary usage of unlikely()
Date: Wed, 6 Jun 2012 11:07:21 +0530
Message-ID: <cfff20b3-8e98-47b0-b093-c7700e986657@exht1.ad.emulex.com>
References: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2015 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753404Ab2FFFwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 01:52:31 -0400
In-Reply-To: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 3aa478f..42ee75b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -719,8 +719,8 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	 * 60 bytes long.
 	 * As a workaround disable TX vlan offloading in such cases.
 	 */
-	if (unlikely(vlan_tx_tag_present(skb) &&
-		     (skb->ip_summed != CHECKSUM_PARTIAL || skb->len <= 60))) {
+	if (vlan_tx_tag_present(skb) &&
+	    (skb->ip_summed != CHECKSUM_PARTIAL || skb->len <= 60)) {
 		skb = skb_share_check(skb, GFP_ATOMIC);
 		if (unlikely(!skb))
 			goto tx_drop;
-- 
1.7.4
