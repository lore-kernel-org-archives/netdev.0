From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-10-30
Date: Mon, 30 Oct 2017 09:39:27 +0100
Message-ID: <1509352775-9563-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:41234 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752525AbdJ3Ijn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 04:39:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Change some variables that can't be negative
   from int to unsigned int. From Alexey Dobriyan.

2) Remove a redundant header initialization in esp6.
   From Colin Ian King.

3) Some BUG to BUG_ON conversions.
   From Gustavo A. R. Silva.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 39e50d9637f9a31967ac9e956b829ee8b50a750f:

  forcedeth: optimize the xmit/rx with unlikely (2017-09-23 20:04:23 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to eee12df5a0bd5769af5efb72fa95dd1f633a266c:

  ipv6: esp6: use BUG_ON instead of if condition followed by BUG (2017-10-27 08:02:00 +0200)

----------------------------------------------------------------
Alexey Dobriyan (5):
      xfrm: make aead_len() return unsigned int
      xfrm: make xfrm_alg_len() return unsigned int
      xfrm: make xfrm_alg_auth_len() return unsigned int
      xfrm: make xfrm_replay_state_esn_len() return unsigned int
      xfrm: eradicate size_t

Colin Ian King (1):
      esp6: remove redundant initialization of esph

Gustavo A. R. Silva (2):
      net: xfrm_user: use BUG_ON instead of if condition followed by BUG
      ipv6: esp6: use BUG_ON instead of if condition followed by BUG

 include/net/xfrm.h   |   8 ++--
 net/ipv6/esp6.c      |   8 ++--
 net/xfrm/xfrm_user.c | 105 ++++++++++++++++++++++++++++-----------------------
 3 files changed, 66 insertions(+), 55 deletions(-)
