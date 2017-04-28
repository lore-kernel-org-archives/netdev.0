From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next 2/3] tc: flower: update headers for TCA_FLOWER_HEADER_PARSE_ERR_ACT
Date: Fri, 28 Apr 2017 14:03:00 +0200
Message-ID: <20170428120301.16500-3-simon.horman@netronome.com>
References: <20170428120301.16500-1-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37273 "EHLO
        mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2993071AbdD1MDU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 08:03:20 -0400
Received: by mail-wm0-f42.google.com with SMTP id m123so44656664wma.0
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2017 05:03:18 -0700 (PDT)
In-Reply-To: <20170428120301.16500-1-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is proposed for net-next.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/pkt_cls.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index f1129e383b2a..1e2dd535703d 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -437,6 +437,8 @@ enum {
 	TCA_FLOWER_KEY_MPLS_TC,		/* u8 - 3 bits */
 	TCA_FLOWER_KEY_MPLS_LABEL,	/* be32 - 20 bits */
 
+	TCA_FLOWER_HEADER_PARSE_ERR_ACT, /* u32 */
+
 	__TCA_FLOWER_MAX,
 };
 
-- 
2.12.2.816.g2cccc81164
