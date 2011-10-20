From: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Subject: [PATCH] ipvs: Fix compilation error in ip_vs.h for ip_vs_confirm_conntrack function.
Date: Thu, 20 Oct 2011 13:18:04 +0100
Message-ID: <1319113084-7498-1-git-send-email-krzysztof.wilczynski@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:36930 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab1JTMSS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 08:18:18 -0400
Received: by wyg36 with SMTP id 36so2800130wyg.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 05:18:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to address the following error during the compilation:

  In file included from kernel/sysctl_binary.c:6:
  include/net/ip_vs.h:1406: error: expected identifier or =E2=80=98(=E2=
=80=99 before =E2=80=98{=E2=80=99 token
  make[1]: *** [kernel/sysctl_binary.o] Error 1
  make[1]: *** Waiting for unfinished jobs....

That manifests itself when CONFIG_IP_VS_NFCT is undefined in .config fi=
le.

Signed-off-by: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
---
 include/net/ip_vs.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index 139784e..de527d1 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1395,7 +1395,7 @@ static inline void ip_vs_update_conntrack(struct =
sk_buff *skb,
 {
 }
=20
-static inline int ip_vs_confirm_conntrack(struct sk_buff *skb);
+static inline int ip_vs_confirm_conntrack(struct sk_buff *skb)
 {
 	return NF_ACCEPT;
 }
--=20
1.7.7
