From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 14/16] irda: remove unnecessary break after return
Date: Mon, 14 Jul 2014 18:36:37 +0200
Message-ID: <1405355799-7691-5-git-send-email-fabf@skynet.be>
References: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Cc: davem@davemloft.net, joe@perches.com,
	Fabian Frederick <fabf@skynet.be>,
	Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay008.isp.belgacom.be ([195.238.6.174]:28504 "EHLO
	mailrelay008.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932184AbaGNQfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 12:35:41 -0400
In-Reply-To: <1405355799-7691-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/irda/af_irda.c            | 1 -
 net/irda/irlan/irlan_common.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index 54747c2..92fafd4 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -674,7 +674,6 @@ static int irda_discover_daddr_and_lsap_sel(struct irda_sock *self, char *name)
 			self->daddr = DEV_ADDR_ANY;
 			kfree(discoveries);
 			return -EHOSTUNREACH;
-			break;
 		}
 	}
 	/* Cleanup our copy of the discovery log */
diff --git a/net/irda/irlan/irlan_common.c b/net/irda/irlan/irlan_common.c
index 7ac4d1b..1bc49ed 100644
--- a/net/irda/irlan/irlan_common.c
+++ b/net/irda/irlan/irlan_common.c
@@ -1024,7 +1024,6 @@ static int __irlan_insert_param(struct sk_buff *skb, char *param, int type,
 	default:
 		IRDA_DEBUG(2, "%s(), Unknown parameter type!\n", __func__ );
 		return 0;
-		break;
 	}
 
 	/* Insert at end of sk-buffer */
-- 
1.8.4.5
