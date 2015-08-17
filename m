From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2015-08-17
Date: Mon, 17 Aug 2015 21:58:17 +0200
Message-ID: <1439841501-20990-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:55662 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751212AbbHQT6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 15:58:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Fix IPv6 ECN decapsulation for IPsec interfamily tunnels.
   From Thomas Egerer.

2) Use kmemdup instead of duplicating it in xfrm_dump_sa().
   From Andrzej Hajda.

3) Pass oif to the xfrm lookups so that it gets set on the flow
   and the resolver routines can match based on oif.
   From David Ahern.

4) Add documentation for the new xfrm garbage collector threshold.
   From Alexander Duyck.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 07a51cd3794960548627a27aae68c1446341db32:

  vxlan: fix fdb_dump index calculation (2015-08-10 21:15:18 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to e69948a0a5309f3ef5715cb4ca7a9bd77d64e2cf:

  net: Document xfrm4_gc_thresh and xfrm6_gc_thresh (2015-08-12 08:28:04 +0200)

----------------------------------------------------------------
Alexander Duyck (1):
      net: Document xfrm4_gc_thresh and xfrm6_gc_thresh

Andrzej Hajda (1):
      net/xfrm: use kmemdup rather than duplicating its implementation

David Ahern (1):
      xfrm: Add oif to dst lookups

Thomas Egerer (1):
      xfrm6: Fix IPv6 ECN decapsulation

 Documentation/networking/ip-sysctl.txt | 10 ++++++++++
 include/net/xfrm.h                     |  7 +++++--
 net/ipv4/xfrm4_policy.c                | 11 ++++++-----
 net/ipv6/xfrm6_mode_tunnel.c           |  3 +--
 net/ipv6/xfrm6_policy.c                |  7 ++++---
 net/xfrm/xfrm_policy.c                 | 24 ++++++++++++++----------
 net/xfrm/xfrm_user.c                   |  6 ++----
 7 files changed, 42 insertions(+), 26 deletions(-)
