From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-04-11
Date: Tue, 11 Apr 2017 07:53:48 +0200
Message-ID: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56574 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752291AbdDKF74 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 01:59:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Remove unused field from struct xfrm_mgr.

2) Code size optimizations for the xfrm prefix hash and
   address match.

3) Branch optimization for addr4_match.

All patches from Alexey Dobriyan.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit add641e7dee31b36aee83412c29e39dd1f5e0c9c:

  sched: act_csum: don't mangle TCP and UDP GSO packets (2017-03-23 17:40:33 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 6c786bcb29dd684533ec165057f437d5bb34a4b2:

  xfrm: branchless addr4_match() on 64-bit (2017-03-27 07:04:14 +0200)

----------------------------------------------------------------
Alexey Dobriyan (4):
      xfrm: remove unused struct xfrm_mgr::id
      xfrm: use "unsigned int" in __xfrm6_pref_hash()
      xfrm: use "unsigned int" in addr_match()
      xfrm: branchless addr4_match() on 64-bit

 include/net/xfrm.h   | 11 +++++------
 net/key/af_key.c     |  1 -
 net/xfrm/xfrm_hash.h |  4 ++--
 net/xfrm/xfrm_user.c |  1 -
 4 files changed, 7 insertions(+), 10 deletions(-)
