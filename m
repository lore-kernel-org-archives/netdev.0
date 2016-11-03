From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2 1/2] tc: update headers for TCA_FLOWER_KEY_SCTP_*
Date: Thu,  3 Nov 2016 13:26:40 +0100
Message-ID: <1478176001-29174-2-git-send-email-simon.horman@netronome.com>
References: <1478176001-29174-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36435 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755112AbcKCM2M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:28:12 -0400
Received: by mail-wm0-f46.google.com with SMTP id p190so329960555wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 05:28:11 -0700 (PDT)
In-Reply-To: <1478176001-29174-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These are proposed changes for net-next.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 include/linux/pkt_cls.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/pkt_cls.h b/include/linux/pkt_cls.h
index b47ed3af22b6..974155a67d2d 100644
--- a/include/linux/pkt_cls.h
+++ b/include/linux/pkt_cls.h
@@ -393,6 +393,11 @@ enum {
 	TCA_FLOWER_KEY_TCP_DST_MASK,	/* be16 */
 	TCA_FLOWER_KEY_UDP_SRC_MASK,	/* be16 */
 	TCA_FLOWER_KEY_UDP_DST_MASK,	/* be16 */
+	TCA_FLOWER_KEY_SCTP_SRC_MASK,   /* be16 */
+	TCA_FLOWER_KEY_SCTP_DST_MASK,   /* be16 */
+
+	TCA_FLOWER_KEY_SCTP_SRC,        /* be16 */
+	TCA_FLOWER_KEY_SCTP_DST,        /* be16 */
 	__TCA_FLOWER_MAX,
 };
 
-- 
2.7.0.rc3.207.g0ac5344
