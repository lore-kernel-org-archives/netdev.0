From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-08-22
Date: Thu, 22 Aug 2013 13:12:04 +0200
Message-ID: <1377169931-7302-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51131 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753299Ab3HVLMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 07:12:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Some constifications, from Mathias Krause.

2) Catch bugs if a hold timer is still active when xfrm_policy_destroy()
   is called, from Fan Du.

3) Remove a redundant address family checking, from Fan Du.

4) Make xfrm_state timer monotonic to be independent of system clock changes,
   from Fan Du.

5) Remove an outdated comment on returning -EREMOTE in the xfrm_lookup(),
   from Rami Rosen.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 5ca5461c3ee8b306c04ac833e5eacb5755b85d88:

  vxlan: fix rcu related warning (2013-08-04 18:47:14 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to e3fec5a1c5a1ab4a85ca3f4e41c626fb953ce162:

  xfrm: remove irrelevant comment in xfrm_input(). (2013-08-19 12:45:16 +0200)

----------------------------------------------------------------
Fan Du (3):
      xfrm: Delete hold_timer when destroy policy
      xfrm: Remove rebundant address family checking
      xfrm: Make xfrm_state timer monotonic

Mathias Krause (2):
      xfrm: constify mark argument of xfrm_find_acq()
      af_key: constify lookup tables

Rami Rosen (1):
      xfrm: remove irrelevant comment in xfrm_input().

 include/net/xfrm.h     |    2 +-
 net/key/af_key.c       |   14 +++-----------
 net/xfrm/xfrm_policy.c |    4 +---
 net/xfrm/xfrm_state.c  |   15 +++++++++------
 4 files changed, 14 insertions(+), 21 deletions(-)
