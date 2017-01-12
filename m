From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 1/2] tc: flower: update headers for TCA_FLOWER_KEY_ARP*
Date: Thu, 12 Jan 2017 09:11:58 +0100
Message-ID: <1484208719-1581-2-git-send-email-simon.horman@netronome.com>
References: <1484208719-1581-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:36637 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750953AbdALIMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 03:12:05 -0500
Received: by mail-wm0-f43.google.com with SMTP id c85so9347558wmi.1
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 00:12:04 -0800 (PST)
In-Reply-To: <1484208719-1581-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Present in net-next.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/pkt_cls.h | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index a081efbd61a2..1e5e1ddfdaca 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -416,6 +416,17 @@ enum {
 	TCA_FLOWER_KEY_ICMPV6_TYPE,	/* u8 */
 	TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,/* u8 */
 
+	TCA_FLOWER_KEY_ARP_SIP,		/* be32 */
+	TCA_FLOWER_KEY_ARP_SIP_MASK,	/* be32 */
+	TCA_FLOWER_KEY_ARP_TIP,		/* be32 */
+	TCA_FLOWER_KEY_ARP_TIP_MASK,	/* be32 */
+	TCA_FLOWER_KEY_ARP_OP,		/* u8 */
+	TCA_FLOWER_KEY_ARP_OP_MASK,	/* u8 */
+	TCA_FLOWER_KEY_ARP_SHA,		/* ETH_ALEN */
+	TCA_FLOWER_KEY_ARP_SHA_MASK,	/* ETH_ALEN */
+	TCA_FLOWER_KEY_ARP_THA,		/* ETH_ALEN */
+	TCA_FLOWER_KEY_ARP_THA_MASK,	/* ETH_ALEN */
+
 	__TCA_FLOWER_MAX,
 };
 
-- 
2.7.0.rc3.207.g0ac5344
