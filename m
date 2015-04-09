From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2015-04-09
Date: Thu, 9 Apr 2015 12:32:09 +0200
Message-ID: <1428575531-24870-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43760 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932620AbbDIKc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 06:32:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) We dereferenced the xfrm outer_mode too early, larval
   SAs don't have it set. Move the dereference of the
   outer mode below the larval SA check to fix it.
   From Alexey Dobriyan.

2) Fix vti6 tunnel uninit on namespace crosssing.
   From Yao Xiwei.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit f22e6e847115abc3a0e2ad7bb18d243d42275af1:

  Linux 4.0-rc7 (2015-04-06 15:39:45 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 092a29a40bab8bb4530bb3e58a0597001cdecdef:

  vti6: fix uninit when using x-netns (2015-04-07 07:52:28 +0200)

----------------------------------------------------------------
Alexey Dobriyan (1):
      xfrm: fix xfrm_input/xfrm_tunnel_check oops

Yao Xiwei (1):
      vti6: fix uninit when using x-netns

 net/ipv6/ip6_vti.c    |  3 +--
 net/xfrm/xfrm_input.c | 10 +++++-----
 2 files changed, 6 insertions(+), 7 deletions(-)
