From: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Subject: [PATCH] ipvs: Remove unused variable "cs" from ip_vs_leave function.
Date: Tue, 18 Oct 2011 20:59:49 +0100
Message-ID: <1318967989-14076-1-git-send-email-krzysztof.wilczynski@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:43872 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753238Ab1JRT7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 15:59:54 -0400
Received: by wwe6 with SMTP id 6so1434501wwe.1
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 12:59:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to address the following warning during compilation time:

  net/netfilter/ipvs/ip_vs_core.c: In function =E2=80=98ip_vs_leave=E2=80=
=99:
  net/netfilter/ipvs/ip_vs_core.c:532: warning: unused variable =E2=80=98=
cs=E2=80=99

This variable is indeed no longer in use.

Signed-off-by: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
---
 net/netfilter/ipvs/ip_vs_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs=
_core.c
index 00ea1ad..4f7d89d 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -529,7 +529,7 @@ int ip_vs_leave(struct ip_vs_service *svc, struct s=
k_buff *skb,
 	   a cache_bypass connection entry */
 	ipvs =3D net_ipvs(net);
 	if (ipvs->sysctl_cache_bypass && svc->fwmark && unicast) {
-		int ret, cs;
+		int ret;
 		struct ip_vs_conn *cp;
 		unsigned int flags =3D (svc->flags & IP_VS_SVC_F_ONEPACKET &&
 				      iph.protocol =3D=3D IPPROTO_UDP)?
--=20
1.7.7
