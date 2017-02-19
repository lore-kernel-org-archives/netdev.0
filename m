From: David Miller <davem@davemloft.net>
Subject: [GIT] Networking
Date: Sat, 18 Feb 2017 22:57:52 -0500 (EST)
Message-ID: <20170218.225752.1904550596272356100.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


One last brown-paper-bag fix for the release.  If we fail the ipv4
mapped source address check, we have to release the route.  From
Willem de Bruijn.

Please pull, thanks a lot!

The following changes since commit 2763f92f858f7c4c3198335c0542726eaed07ba3:

  Merge tag 'fixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/arm/arm-soc (2017-02-18 17:38:09 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git 

for you to fetch changes up to 00ea1ceebe0d9f2dc1cc2b7bd575a00100c27869:

  ipv6: release dst on error in ip6_dst_lookup_tail (2017-02-18 22:55:13 -0500)

----------------------------------------------------------------
Willem de Bruijn (1):
      ipv6: release dst on error in ip6_dst_lookup_tail

 net/ipv6/ip6_output.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)
