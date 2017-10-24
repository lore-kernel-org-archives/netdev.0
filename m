From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-10-24
Date: Tue, 24 Oct 2017 12:37:38 +0200
Message-ID: <1508841460-26369-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:39110 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751825AbdJXKhs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Oct 2017 06:37:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix a memleak when we don't find a inner_mode
   during bundle creation. From David Miller.

2) Fix a xfrm policy dump crash. We may crash
   on error when dumping policies via netlink.
   Fix this by initializing the policy walk
   with the cb->start method. This fix is a
   serious stable candidate. From Herbert Xu.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit c0576e3975084d4699b7bfef578613fb8e1144f6:

  net: call cgroup_sk_alloc() earlier in sk_clone_lock() (2017-10-10 20:24:29 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 1137b5e2529a8f5ca8ee709288ecba3e68044df2:

  ipsec: Fix aborted xfrm policy dump crash (2017-10-23 09:35:48 +0200)

----------------------------------------------------------------
David Miller (1):
      ipsec: Fix dst leak in xfrm_bundle_create().

Herbert Xu (1):
      ipsec: Fix aborted xfrm policy dump crash

 net/xfrm/xfrm_policy.c | 16 ++++++++--------
 net/xfrm/xfrm_user.c   | 25 +++++++++++++++----------
 2 files changed, 23 insertions(+), 18 deletions(-)
