From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next 1/3] tc: flower: update headers for TCA_FLOWER_KEY_MPLS*
Date: Fri, 28 Apr 2017 14:02:59 +0200
Message-ID: <20170428120301.16500-2-simon.horman@netronome.com>
References: <20170428120301.16500-1-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:37262 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2992797AbdD1MDS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 08:03:18 -0400
Received: by mail-wm0-f47.google.com with SMTP id m123so44656201wma.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 05:03:17 -0700 (PDT)
In-Reply-To: <20170428120301.16500-1-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These changes are present in net-next.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/pkt_cls.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 7a69f2a4ca0c..f1129e383b2a 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -432,6 +432,11 @@ enum {
 	TCA_FLOWER_KEY_ARP_THA,		/* ETH_ALEN */
 	TCA_FLOWER_KEY_ARP_THA_MASK,	/* ETH_ALEN */
 
+	TCA_FLOWER_KEY_MPLS_TTL,	/* u8 - 8 bits */
+	TCA_FLOWER_KEY_MPLS_BOS,	/* u8 - 1 bit */
+	TCA_FLOWER_KEY_MPLS_TC,		/* u8 - 3 bits */
+	TCA_FLOWER_KEY_MPLS_LABEL,	/* be32 - 20 bits */
+
 	__TCA_FLOWER_MAX,
 };
 
-- 
2.12.2.816.g2cccc81164
