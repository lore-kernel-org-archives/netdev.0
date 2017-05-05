From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC iproute2/net-next v2 1/2] tc: flower: update headers for TCA_FLOWER_META_TRUNCATED
Date: Fri,  5 May 2017 14:51:24 +0200
Message-ID: <1493988685-7891-2-git-send-email-simon.horman@netronome.com>
References: <1493988685-7891-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34867 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753645AbdEEMvu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 08:51:50 -0400
Received: by mail-wm0-f49.google.com with SMTP id w64so23043585wma.0
        for <netdev@vger.kernel.org>; Fri, 05 May 2017 05:51:49 -0700 (PDT)
In-Reply-To: <1493988685-7891-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change is proposed for net-next.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/pkt_cls.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index f1129e383b2a..dfbd5137e275 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -437,6 +437,8 @@ enum {
 	TCA_FLOWER_KEY_MPLS_TC,		/* u8 - 3 bits */
 	TCA_FLOWER_KEY_MPLS_LABEL,	/* be32 - 20 bits */
 
+	TCA_FLOWER_META_TRUNCATED,	/* u32 */
+
 	__TCA_FLOWER_MAX,
 };
 
-- 
2.1.4
