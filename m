From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2 iproute2/net-next 1/3] tc: flower: update headers for TCA_FLOWER_KEY_ICMP*
Date: Wed,  7 Dec 2016 14:54:01 +0100
Message-ID: <1481118843-10428-2-git-send-email-simon.horman@netronome.com>
References: <1481118843-10428-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35060 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752563AbcLGNzr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 08:55:47 -0500
Received: by mail-wm0-f52.google.com with SMTP id a197so168962228wmd.0
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 05:54:50 -0800 (PST)
In-Reply-To: <1481118843-10428-1-git-send-email-simon.horman@netronome.com>
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
