From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH iproute2 -next 2/3] include/linux: update xfrm.h
Date: Mon,  3 Mar 2014 15:36:06 +0100
Message-ID: <1393857367-15016-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1393857367-15016-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:55422 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbaCCOgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 09:36:19 -0500
In-Reply-To: <1393857367-15016-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Note that this patch is based on net-next.

 include/linux/xfrm.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 341c3c951dac..694aa90df7d8 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -298,6 +298,8 @@ enum xfrm_attr_type_t {
 	XFRMA_TFCPAD,		/* __u32 */
 	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
+	XFRMA_PROTO,		/* __u8 */
+	XFRMA_FILTER,		/* struct xfrm_filter */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -474,6 +476,14 @@ struct xfrm_user_mapping {
 	__be16				new_sport;
 };
 
+struct xfrm_filter {
+	xfrm_address_t			saddr;
+	xfrm_address_t			daddr;
+	__u16				family;
+	__u8				splen;
+	__u8				dplen;
+};
+
 /* backwards compatibility for userspace */
 #define XFRMGRP_ACQUIRE		1
 #define XFRMGRP_EXPIRE		2
-- 
1.8.5.4
