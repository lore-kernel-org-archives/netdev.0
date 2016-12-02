From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 1/3] tc: flower: update headers for TCA_FLOWER_KEY_ICMP*
Date: Fri,  2 Dec 2016 19:24:37 +0100
Message-ID: <1480703079-25422-2-git-send-email-simon.horman@netronome.com>
References: <1480703079-25422-1-git-send-email-simon.horman@netronome.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f175.google.com ([209.85.210.175]:35622 "EHLO
        mail-wj0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752930AbcLBSZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:25:51 -0500
Received: by mail-wj0-f175.google.com with SMTP id v7so238874429wjy.2
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:24:55 -0800 (PST)
In-Reply-To: <1480703079-25422-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are proposed changes for net-next.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/pkt_cls.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index a3d8a4f17d8e..fa435ea8ad21 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -403,6 +403,16 @@ enum {
 	TCA_FLOWER_KEY_ENC_UDP_SRC_PORT_MASK,	/* be16 */
 	TCA_FLOWER_KEY_ENC_UDP_DST_PORT,	/* be16 */
 	TCA_FLOWER_KEY_ENC_UDP_DST_PORT_MASK,	/* be16 */
+
+	TCA_FLOWER_KEY_ICMPV4_CODE,     /* u8 */
+	TCA_FLOWER_KEY_ICMPV4_CODE_MASK,/* u8 */
+	TCA_FLOWER_KEY_ICMPV4_TYPE,     /* u8 */
+	TCA_FLOWER_KEY_ICMPV4_TYPE_MASK,/* u8 */
+	TCA_FLOWER_KEY_ICMPV6_CODE,     /* u8 */
+	TCA_FLOWER_KEY_ICMPV6_CODE_MASK,/* u8 */
+	TCA_FLOWER_KEY_ICMPV6_TYPE,     /* u8 */
+	TCA_FLOWER_KEY_ICMPV6_TYPE_MASK,/* u8 */
+
 	__TCA_FLOWER_MAX,
 };
 
-- 
2.7.0.rc3.207.g0ac5344
