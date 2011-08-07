From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 06 Aug 2011 18:51:39 -0700 (PDT)
Message-ID: <20110806.185139.503343378584779938.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44810 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756791Ab1HGBvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 21:51:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull to get the MD5 sequence number changes.

Thanks!

The following changes since commit de96355c111679dd6e2c5c73e25e814c72510c58:

  Merge branch 'drm-fixes' of git://git.kernel.org/pub/scm/linux/kernel/git/airlied/drm-2.6 (2011-08-05 06:44:38 -1000)

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net.git master

David S. Miller (2):
      crypto: Move md5_transform to lib/md5.c
      net: Compute protocol sequence numbers and fragment IDs using MD5.

 crypto/md5.c                             |   92 +--------
 drivers/char/random.c                    |  349 +-----------------------------
 include/linux/cryptohash.h               |    5 +
 include/linux/random.h                   |   12 -
 include/net/secure_seq.h                 |   20 ++
 lib/Makefile                             |    2 +-
 lib/md5.c                                |   95 ++++++++
 net/core/Makefile                        |    2 +-
 net/core/secure_seq.c                    |  184 ++++++++++++++++
 net/dccp/ipv4.c                          |    1 +
 net/dccp/ipv6.c                          |    9 +-
 net/ipv4/inet_hashtables.c               |    1 +
 net/ipv4/inetpeer.c                      |    1 +
 net/ipv4/netfilter/nf_nat_proto_common.c |    1 +
 net/ipv4/route.c                         |    1 +
 net/ipv4/tcp_ipv4.c                      |    1 +
 net/ipv6/inet6_hashtables.c              |    1 +
 net/ipv6/tcp_ipv6.c                      |    1 +
 18 files changed, 325 insertions(+), 453 deletions(-)
 create mode 100644 include/net/secure_seq.h
 create mode 100644 lib/md5.c
 create mode 100644 net/core/secure_seq.c
