From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 10/14] openvswitch: Fix the type of struct ovs_key_nd nd_target field.
Date: Thu,  6 Nov 2014 01:19:36 -0800
Message-ID: <1415265576-1814-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Jarno Rajahalme <jrajahalme@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog131.obsmtp.com ([74.125.149.247]:46322 "HELO
	na3sys009aog131.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752022AbaKFJTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2014 04:19:39 -0500
Received: by mail-pd0-f172.google.com with SMTP id r10so782990pdi.31
        for <netdev@vger.kernel.org>; Thu, 06 Nov 2014 01:19:38 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarno Rajahalme <jrajahalme@nicira.com>

Should be the same as other IPv6 address fields.

Current master produces sparse warnings without this change.

Signed-off-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/uapi/linux/openvswitch.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 631056b..26c36c4 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -400,9 +400,9 @@ struct ovs_key_arp {
 };
 
 struct ovs_key_nd {
-	__u32 nd_target[4];
-	__u8  nd_sll[ETH_ALEN];
-	__u8  nd_tll[ETH_ALEN];
+	__be32	nd_target[4];
+	__u8	nd_sll[ETH_ALEN];
+	__u8	nd_tll[ETH_ALEN];
 };
 
 /**
-- 
1.9.3
