From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2016-11-25
Date: Fri, 25 Nov 2016 07:57:57 +0100
Message-ID: <1480057080-20177-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c.mx.secunet.com ([62.96.220.56]:45292 "EHLO c.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752756AbcKYHH0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Nov 2016 02:07:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix a refcount leak in vti6.
   From Nicolas Dichtel.

2) Fix a wrong if statement in xfrm_sk_policy_lookup.
   From Florian Westphal.

3) The flowcache watermarks are per cpu. Take this into
   account when comparing to the threshold where we
   refusing new allocations. From Miroslav Urbanek.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit d24cd733bae8fc6c121c437b3197ab7f3930ca66:

  Merge branch 'be2net-fixes' (2016-10-09 09:30:45 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 6b226487815574193c1da864f2eac274781a2b0c:

  flowcache: Increase threshold for refusing new allocations (2016-11-23 06:37:09 +0100)

----------------------------------------------------------------
Florian Westphal (1):
      xfrm: unbreak xfrm_sk_policy_lookup

Miroslav Urbanek (1):
      flowcache: Increase threshold for refusing new allocations

Nicolas Dichtel (1):
      vti6: flush x-netns xfrm cache when vti interface is removed

 net/core/flow.c        |  6 ++----
 net/ipv6/ip6_vti.c     | 31 +++++++++++++++++++++++++++++++
 net/xfrm/xfrm_policy.c | 10 ++++++----
 3 files changed, 39 insertions(+), 8 deletions(-)
