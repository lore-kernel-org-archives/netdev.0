From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2014-07-23
Date: Wed, 23 Jul 2014 10:18:05 +0200
Message-ID: <1406103487-1656-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39827 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757233AbaGWIS1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2014 04:18:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just two fixes this time, both are stable candidates.

1) Fix the dst_entry refcount on socket policy usage.

2) Fix a wrong SPI check that prevents AH SAs from getting
   installed, dependent on the SPI. From Tobias Brunner. 

Please pull or let me know if there are problems.

Thanks!

The following changes since commit d7933ab727ed035bdf420d7381b831ba959cecc5:

  Merge branch 'for-next' of git://git.samba.org/sfrench/cifs-2.6 (2014-06-25 21:47:28 -0700)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to a0e5ef53aac8e5049f9344857d8ec5237d31e58b:

  xfrm: Fix installation of AH IPsec SAs (2014-06-30 07:42:12 +0200)

----------------------------------------------------------------
Steffen Klassert (1):
      xfrm: Fix refcount imbalance in xfrm_lookup

Tobias Brunner (1):
      xfrm: Fix installation of AH IPsec SAs

 net/xfrm/xfrm_policy.c | 2 ++
 net/xfrm/xfrm_user.c   | 7 +++----
 2 files changed, 5 insertions(+), 4 deletions(-)
