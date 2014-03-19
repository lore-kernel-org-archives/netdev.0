From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v2 iproute2 -next 1/2] include/linux: update xfrm.h
Date: Wed, 19 Mar 2014 17:52:07 +0100
Message-ID: <1395247928-9954-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:56168 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932602AbaCSQwe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2014 12:52:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---

Note that this patch is based on net-next.

 include/linux/xfrm.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index 341c3c951dac..fa2ecb2eb998 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -298,6 +298,8 @@ enum xfrm_attr_type_t {
 	XFRMA_TFCPAD,		/* __u32 */
 	XFRMA_REPLAY_ESN_VAL,	/* struct xfrm_replay_esn */
 	XFRMA_SA_EXTRA_FLAGS,	/* __u32 */
+	XFRMA_PROTO,		/* __u8 */
+	XFRMA_ADDRESS_FILTER,	/* struct xfrm_address_filter */
 	__XFRMA_MAX
 
 #define XFRMA_MAX (__XFRMA_MAX - 1)
@@ -474,6 +476,14 @@ struct xfrm_user_mapping {
 	__be16				new_sport;
 };
 
+struct xfrm_address_filter {
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
