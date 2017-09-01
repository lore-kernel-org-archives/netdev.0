From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-09-01
Date: Fri, 1 Sep 2017 09:30:44 +0200
Message-ID: <1504251046-17106-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50288 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751422AbdIAHaw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 03:30:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This should be the last ipsec-next pull request for this
release cycle:

1) Support netdevice ESP trailer removal when decryption
   is offloaded. From Yossi Kuperman.

2) Fix overwritten return value of copy_sec_ctx().

Please pull or let me know if there are problems.

Thanks!

The following changes since commit acfb98b99647aa7dc7c111db52d5f4199d2b641f:

  liquidio: fix crash in presence of zeroed-out base address regs (2017-08-30 22:07:09 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 8598112d04af21cf6c895670e72dcb8a9f58e74f:

  xfrm: Fix return value check of copy_sec_ctx. (2017-08-31 10:37:00 +0200)

----------------------------------------------------------------
Steffen Klassert (1):
      xfrm: Fix return value check of copy_sec_ctx.

Yossi Kuperman (1):
      xfrm: Add support for network devices capable of removing the ESP trailer

 include/net/xfrm.h    |  1 +
 net/ipv4/esp4.c       | 70 ++++++++++++++++++++++++++++++++++-----------------
 net/ipv6/esp6.c       | 51 ++++++++++++++++++++++++++-----------
 net/xfrm/xfrm_input.c |  5 ++++
 net/xfrm/xfrm_user.c  |  4 +--
 5 files changed, 91 insertions(+), 40 deletions(-)
