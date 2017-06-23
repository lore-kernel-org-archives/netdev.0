From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-06-23
Date: Fri, 23 Jun 2017 10:38:24 +0200
Message-ID: <1498207110-22520-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51102 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753368AbdFWIih (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 04:38:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Use memdup_user to spmlify xfrm_user_policy.
   From Geliang Tang.

2) Make xfrm_dev_register static to silence a sparse warning.
   From Wei Yongjun.

3) Use crypto_memneq to check the ICV in the AH protocol.
   From Sabrina Dubroca.

4) Remove some unused variables in esp6.
   From Stephen Hemminger.

5) Extend XFRM MIGRATE to allow to change the UDP encapsulation port.
   From Antony Antony.

6) Include the UDP encapsulation port to km_migrate announcements.
   From Antony Antony.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit a95cfad947d5f40cfbf9ad3019575aac1d8ac7a6:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-05-15 15:50:49 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 8bafd73093f2f431f5a363f8057abc0ccc118853:

  xfrm: add UDP encapsulation port in migrate message (2017-06-07 08:35:54 +0200)

----------------------------------------------------------------
Antony Antony (2):
      xfrm: extend MIGRATE with UDP encapsulation port
      xfrm: add UDP encapsulation port in migrate message

Geliang Tang (1):
      xfrm: use memdup_user

Sabrina Dubroca (1):
      ah: use crypto_memneq to check the ICV

Stephen Hemminger (1):
      ipv6: remove unused variables in esp6

Wei Yongjun (1):
      xfrm: Make function xfrm_dev_register static

 include/net/xfrm.h     | 12 ++++++++----
 net/ipv4/ah4.c         |  5 +++--
 net/ipv6/ah6.c         |  5 +++--
 net/ipv6/esp6.c        |  5 -----
 net/key/af_key.c       |  8 +++++---
 net/xfrm/xfrm_device.c |  2 +-
 net/xfrm/xfrm_policy.c | 13 +++++--------
 net/xfrm/xfrm_state.c  | 35 ++++++++++++++++++++---------------
 net/xfrm/xfrm_user.c   | 37 +++++++++++++++++++++++++++++--------
 9 files changed, 74 insertions(+), 48 deletions(-)
