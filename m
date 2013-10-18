From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-10-18
Date: Fri, 18 Oct 2013 10:42:06 +0200
Message-ID: <1382085730-3415-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51699 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753191Ab3JRImU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Oct 2013 04:42:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Don't use a wildcard SA if a more precise one is in acquire state,
   from Fan Du.

2) Simplify the SA lookup when using wildcard source. We need to check
   only the destination in this case, from Fan Du.

3) Add a receive path hook for IPsec virtual tunnel interfaces
   to xfrm6_mode_tunnel.

4) Add support for IPsec virtual tunnel interfaces to ipv6.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit b32418705107265dfca5edfe2b547643e53a732e:

  bonding: RCUify bond_set_rx_mode() (2013-09-30 22:26:41 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to ed1efb2aefbbc6f5a3da5b42158bfb753ba6fe82:

  ipv6: Add support for IPsec virtual tunnel interfaces (2013-10-10 12:00:01 +0200)

----------------------------------------------------------------
Fan Du (2):
      xfrm: Force SA to be lookup again if SA in acquire state
      xfrm: Simplify SA looking up when using wildcard source

Steffen Klassert (2):
      ipv6: Add a receive path hook for vti6 in xfrm6_mode_tunnel.
      ipv6: Add support for IPsec virtual tunnel interfaces

 include/net/xfrm.h           |    2 +
 net/ipv6/Kconfig             |   11 +
 net/ipv6/Makefile            |    1 +
 net/ipv6/ip6_vti.c           | 1056 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/xfrm6_mode_tunnel.c |   69 +++
 net/xfrm/xfrm_state.c        |    4 +-
 6 files changed, 1141 insertions(+), 2 deletions(-)
 create mode 100644 net/ipv6/ip6_vti.c
