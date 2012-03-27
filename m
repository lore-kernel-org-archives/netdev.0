From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Tue, 27 Mar 2012 18:51:29 -0400 (EDT)
Message-ID: <20120327.185129.633367112180291954.davem@davemloft.net>
References: <20120325.175151.853542033329072696.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120325.175151.853542033329072696.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Sun, 25 Mar 2012 17:51:51 -0400 (EDT)

> 1) Name string overrun fix in gianfar driver from Joe Perches.
 ...
> 
> Please pull, thanks a lot!

I don't know if you've pulled this or not, but I just wanted to let
you know that I just added the following critical fix to my tree
which I'd like to propagate to -stable ASAP.

So if you have pulled, if you would repull to get this guy, I'd
really appreciate it.

Thanks a lot!

The following changes since commit 50269e19ad990e79eeda101fc6df80cffd5d4831:

  net: add a truesize parameter to skb_add_rx_frag() (2012-03-25 13:29:58 -0400)

are available in the git repository at:
  gitolite@ra.kernel.org:/pub/scm/linux/kernel/git/davem/net.git master

Eric Dumazet (1):
      net: fix a potential rcu_read_lock() imbalance in rt6_fill_node()

 net/ipv6/route.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)
