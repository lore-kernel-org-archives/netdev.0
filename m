From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2016-09-23
Date: Fri, 23 Sep 2016 09:14:40 +0200
Message-ID: <1474614882-25253-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:45176 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757328AbcIWHOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Sep 2016 03:14:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only two patches this time:

1) Fix a comment reference to struct xfrm_replay_state_esn.
   From Richard Guy Briggs.

2) Convert xfrm_state_lookup to rcu, we don't need the
   xfrm_state_lock anymore in the input path.
   From Florian Westphal.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 2d2be8cab26ed918e94d2deae89580003242a123:

  bpf: fix range propagation on direct packet access (2016-09-08 17:28:37 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to c2f672fc94642bae96821a393f342edcfa9794a6:

  xfrm: state lookup can be lockless (2016-09-21 12:37:29 +0200)

----------------------------------------------------------------
Florian Westphal (1):
      xfrm: state lookup can be lockless

Richard Guy Briggs (1):
      xfrm: fix header file comment reference to struct xfrm_replay_state_esn

 include/uapi/linux/xfrm.h | 2 +-
 net/xfrm/xfrm_state.c     | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)
