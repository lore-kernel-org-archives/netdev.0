From: Varsha Rao <rvarsha016@gmail.com>
Subject: [PATCH 2/2] net: ipv4: Use BIT macro.
Date: Thu, 30 Mar 2017 00:46:44 +0530
Message-ID: <58dc0820.8943620a.67760.546e@mx.google.com>
References: <cover.1490813977.git.rvarsha016@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: outreachy-kernel <outreachy-kernel@googlegroups.com>,
        netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36205 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753003AbdC2TQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 15:16:49 -0400
Received: by mail-pg0-f66.google.com with SMTP id 81so4065700pgh.3
        for <netdev@vger.kernel.org>; Wed, 29 Mar 2017 12:16:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <cover.1490813977.git.rvarsha016@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace bitwise left shift by one operations with BIT() macro. This patch
fixes the checkpatch issue.

Signed-off-by: Varsha Rao <rvarsha016@gmail.com>
---
 net/ipv4/tcp_bbr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp_bbr.c
index 4da4bc1..9f2c869 100644
--- a/net/ipv4/tcp_bbr.c
+++ b/net/ipv4/tcp_bbr.c
@@ -71,10 +71,10 @@
  * an issue. The upper bound isn't an issue with existing technologies.
  */
 #define BW_SCALE 24
-#define BW_UNIT (1 << BW_SCALE)
+#define BW_UNIT BIT(BW_SCALE)
 
 #define BBR_SCALE 8	/* scaling factor for fractions in BBR (e.g. gains) */
-#define BBR_UNIT (1 << BBR_SCALE)
+#define BBR_UNIT BIT(BBR_SCALE)
 
 /* BBR has the following modes for deciding how fast to send: */
 enum bbr_mode {
-- 
2.9.3
