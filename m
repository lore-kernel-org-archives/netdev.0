From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-09-26
Date: Thu, 26 Sep 2013 10:58:41 +0200
Message-ID: <1380185923-8976-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34315 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821Ab3IZI7M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 04:59:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two patches that are left from the last development cycle.
Manual merging of include/net/xfrm.h is needed. The conflict
can be solved as it is currently done in linux-next.

1) We announce the creation of temporary acquire state via an asyc event,
   so the deletion should be annunced too. From Nicolas Dichtel.

2) The VTI tunnels do not real tunning, they just provide a routable
   IPsec tunnel interface. So introduce and use xfrm_tunnel_notifier
   instead of xfrm_tunnel for xfrm tunnel mode callback. From Fan Du.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit b4de77ade3fc56e41b978b68d78a351dab28b74e:

  ipip: potential race in ip_tunnel_init_net() (2013-08-25 18:39:59 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to aba8269588301f7778bea811d6f7ec74c2e37279:

  {ipv4,xfrm}: Introduce xfrm_tunnel_notifier for xfrm tunnel mode callback (2013-08-28 09:22:17 +0200)

----------------------------------------------------------------
Fan Du (1):
      {ipv4,xfrm}: Introduce xfrm_tunnel_notifier for xfrm tunnel mode callback

Nicolas Dichtel (1):
      xfrm: announce deleation of temporary SA

 include/net/xfrm.h           |   10 +++++--
 net/ipv4/ip_vti.c            |   67 +-----------------------------------------
 net/ipv4/xfrm4_mode_tunnel.c |   16 +++++-----
 net/xfrm/xfrm_state.c        |    2 +-
 4 files changed, 18 insertions(+), 77 deletions(-)
