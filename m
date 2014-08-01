From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: [PATCH RFC iproute2 1/2] Update headers to net-next
Date: Fri,  1 Aug 2014 15:01:09 +0200
Message-ID: <1406898070-15942-2-git-send-email-christophe.gouault@6wind.com>
References: <1406884348-12423-3-git-send-email-christophe.gouault@6wind.com>
 <1406898070-15942-1-git-send-email-christophe.gouault@6wind.com>
Cc: netdev@vger.kernel.org,
	Christophe Gouault <christophe.gouault@6wind.com>
To: "David S. Miller" <davem@davemloft.net>,
	Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:48517 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755280AbaHANBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2014 09:01:53 -0400
Received: by mail-we0-f172.google.com with SMTP id x48so4279851wes.17
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2014 06:01:51 -0700 (PDT)
In-Reply-To: <1406898070-15942-1-git-send-email-christophe.gouault@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 include/linux/xfrm.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index fa2ecb2..3a1fd32 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -328,6 +328,8 @@ enum xfrm_spdattr_type_t {
 	XFRMA_SPD_UNSPEC,
 	XFRMA_SPD_INFO,
 	XFRMA_SPD_HINFO,
+	XFRMA_SPD_IPV4_HTHRESH,
+	XFRMA_SPD_IPV6_HTHRESH,
 	__XFRMA_SPD_MAX
 
 #define XFRMA_SPD_MAX (__XFRMA_SPD_MAX - 1)
@@ -347,6 +349,11 @@ struct xfrmu_spdhinfo {
 	__u32 spdhmcnt;
 };
 
+struct xfrmu_spdhthresh {
+	__u8 lbits;
+	__u8 rbits;
+};
+
 struct xfrm_usersa_info {
 	struct xfrm_selector		sel;
 	struct xfrm_id			id;
-- 
1.9.1
