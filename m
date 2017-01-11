From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next 1/2] tc: flower: update headers for TCA_FLOWER_KEY_ARP*
Date: Wed, 11 Jan 2017 11:03:03 +0100
Message-ID: <1484128984-11891-2-git-send-email-simon.horman@netronome.com>
References: <1484128984-11891-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37156 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965516AbdAKKDO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 05:03:14 -0500
Received: by mail-wm0-f42.google.com with SMTP id c206so105609087wme.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 02:03:13 -0800 (PST)
In-Reply-To: <1484128984-11891-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are proposed changes for net-next.

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
