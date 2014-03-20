From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH v3 iproute2 -next 1/2] include/linux: update xfrm.h
Date: Thu, 20 Mar 2014 11:16:16 +0100
Message-ID: <1395310577-10901-1-git-send-email-nicolas.dichtel@6wind.com>
References: <20140319133955.6458fe5a@nehalam.linuxnetplumber.net>
Cc: netdev@vger.kernel.org, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:57563 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755217AbaCTKQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 06:16:24 -0400
In-Reply-To: <20140319133955.6458fe5a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
Note that this patch is based on net-next.

v3: use C99 initializers

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
