From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2016-12-01
Date: Thu, 1 Dec 2016 12:44:49 +0100
Message-ID: <1480592692-3653-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50026 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752437AbcLALpD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Dec 2016 06:45:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Change the error value when someone tries to run 32bit
   userspace on a 64bit host from -ENOTSUPP to the userspace
   exported -EOPNOTSUPP. Fix from Yi Zhao.

2) On inbound, ESN sequence numbers are already in network
   byte order. So don't try to convert it again, this fixes
   integrity verification for ESN. Fixes from Tobias Brunner.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit f2ebf2a6ca94e78be179e8c99d34c87efc5e8bfb:

  Merge branch 'fixed-phy-phydev-leaks' (2016-11-29 23:17:04 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to a55e23864d381c5a4ef110df94b00b2fe121a70d:

  esp6: Fix integrity verification when ESN are used (2016-11-30 11:10:16 +0100)

----------------------------------------------------------------
Tobias Brunner (2):
      esp4: Fix integrity verification when ESN are used
      esp6: Fix integrity verification when ESN are used

Yi Zhao (1):
      xfrm_user: fix return value from xfrm_user_rcv_msg

 net/ipv4/esp4.c      | 2 +-
 net/ipv6/esp6.c      | 2 +-
 net/xfrm/xfrm_user.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)
