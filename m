From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/xfrm/: remove unused exports
Date: Wed, 30 Jan 2008 22:02:21 +0200
Message-ID: <20080130200221.GR29368@does.not.exist>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:51731 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756023AbYA3UBq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jan 2008 15:01:46 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes the following no longer used EXPORT_SYMBOL's:
- xfrm_input.c: xfrm_parse_spi
- xfrm_state.c: xfrm_replay_check
- xfrm_state.c: xfrm_replay_advance

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 net/xfrm/xfrm_input.c |    1 -
 net/xfrm/xfrm_state.c |    2 --
 2 files changed, 3 deletions(-)

03a968fa089d9d1a700875af339b263b6fff4ff3 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 039e701..d32b67a 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -81,7 +81,6 @@ int xfrm_parse_spi(struct sk_buff *skb, u8 nexthdr, __be32 *spi, __be32 *seq)
 	*seq = *(__be32*)(skb_transport_header(skb) + offset_seq);
 	return 0;
 }
-EXPORT_SYMBOL(xfrm_parse_spi);
 
 int xfrm_prepare_input(struct xfrm_state *x, struct sk_buff *skb)
 {
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 3003503..15daed0 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -1645,7 +1645,6 @@ err:
 	xfrm_audit_state_replay(x, skb, net_seq);
 	return -EINVAL;
 }
-EXPORT_SYMBOL(xfrm_replay_check);
 
 void xfrm_replay_advance(struct xfrm_state *x, __be32 net_seq)
 {
@@ -1667,7 +1666,6 @@ void xfrm_replay_advance(struct xfrm_state *x, __be32 net_seq)
 	if (xfrm_aevent_is_on())
 		xfrm_replay_notify(x, XFRM_REPLAY_UPDATE);
 }
-EXPORT_SYMBOL(xfrm_replay_advance);
 
 static LIST_HEAD(xfrm_km_list);
 static DEFINE_RWLOCK(xfrm_km_lock);

