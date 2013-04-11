From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-04-11
Date: Thu, 11 Apr 2013 09:56:07 +0200
Message-ID: <1365666969-22645-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56585 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537Ab3DKH4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 03:56:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1)  Allow to avoid copying DSCP during encapsulation
    by setting a SA flag. From Nicolas Dichtel.

2) Constify the netlink dispatch table, no need to modify it
   at runtime. From Mathias Krause.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 6fac41157252220678b210fcb13e2c3dad7a912a:

  bnx2x: use the default NAPI weight (2013-03-05 23:40:01 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 05600a799f6c67b139f2bc565e358b913b230cf5:

  xfrm_user: constify netlink dispatch table (2013-03-06 07:02:46 +0100)

----------------------------------------------------------------
Mathias Krause (1):
      xfrm_user: constify netlink dispatch table

Nicolas Dichtel (1):
      xfrm: allow to avoid copying DSCP during encapsulation

 include/net/xfrm.h           |    1 +
 include/uapi/linux/xfrm.h    |    3 +++
 net/ipv4/ipcomp.c            |    1 +
 net/ipv4/xfrm4_mode_tunnel.c |    8 ++++++--
 net/ipv6/xfrm6_mode_tunnel.c |    7 +++++--
 net/xfrm/xfrm_state.c        |    1 +
 net/xfrm/xfrm_user.c         |   17 +++++++++++++++--
 7 files changed, 32 insertions(+), 6 deletions(-)
