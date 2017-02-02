From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 6/7] tc: flower: Add TCA_FLOWER_KEY_ND_*
Date: Thu,  2 Feb 2017 11:38:39 +0100
Message-ID: <1486031920-10784-7-git-send-email-simon.horman@netronome.com>
References: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37250 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdBBKjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 05:39:01 -0500
Received: by mail-wm0-f51.google.com with SMTP id v77so81435580wmv.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 02:39:00 -0800 (PST)
In-Reply-To: <1486031920-10784-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changes proposed for net-next.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/pkt_cls.h | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index 345551e71410..fc9e9bef726e 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -430,6 +430,13 @@ enum {
 	TCA_FLOWER_KEY_ARP_THA,		/* ETH_ALEN */
 	TCA_FLOWER_KEY_ARP_THA_MASK,	/* ETH_ALEN */
 
+	TCA_FLOWER_KEY_ND_TARGET,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ND_TARGET_MASK,	/* struct in6_addr */
+	TCA_FLOWER_KEY_ND_SLL,		/* ETH_ALEN */
+	TCA_FLOWER_KEY_ND_SLL_MASK,	/* ETH_ALEN */
+	TCA_FLOWER_KEY_ND_TLL,		/* ETH_ALEN */
+	TCA_FLOWER_KEY_ND_TLL_MASK,	/* ETH_ALEN */
+
 	__TCA_FLOWER_MAX,
 };
 
-- 
2.7.0.rc3.207.g0ac5344
