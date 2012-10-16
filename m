From: nicolas.dichtel@6wind.com
Subject: [PATCH] xfrm: use ISO C standard for array in linux/xfrm.h
Date: Tue, 16 Oct 2012 17:42:33 +0200
Message-ID: <1350402153-3889-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: herbert@gondor.apana.org.au, steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:51422 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754895Ab2JPPfv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2012 11:35:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Use the ISO C standard compliant form instead of the gcc extension.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/uapi/linux/xfrm.h | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/uapi/linux/xfrm.h b/include/uapi/linux/xfrm.h
index 28e493b..6a6a605 100644
--- a/include/uapi/linux/xfrm.h
+++ b/include/uapi/linux/xfrm.h
@@ -30,7 +30,7 @@ struct xfrm_sec_ctx {
 	__u8	ctx_alg;
 	__u16	ctx_len;
 	__u32	ctx_sid;
-	char	ctx_str[0];
+	char	ctx_str[];
 };
 
 /* Security Context Domains of Interpretation */
@@ -93,27 +93,27 @@ struct xfrm_replay_state_esn {
 	__u32		oseq_hi;
 	__u32		seq_hi;
 	__u32		replay_window;
-	__u32		bmp[0];
+	__u32		bmp[];
 };
 
 struct xfrm_algo {
 	char		alg_name[64];
 	unsigned int	alg_key_len;    /* in bits */
-	char		alg_key[0];
+	char		alg_key[];
 };
 
 struct xfrm_algo_auth {
 	char		alg_name[64];
 	unsigned int	alg_key_len;    /* in bits */
 	unsigned int	alg_trunc_len;  /* in bits */
-	char		alg_key[0];
+	char		alg_key[];
 };
 
 struct xfrm_algo_aead {
 	char		alg_name[64];
 	unsigned int	alg_key_len;	/* in bits */
 	unsigned int	alg_icv_len;	/* in bits */
-	char		alg_key[0];
+	char		alg_key[];
 };
 
 struct xfrm_stats {
-- 
1.7.12
