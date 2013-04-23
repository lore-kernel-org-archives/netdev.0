From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Tue, 23 Apr 2013 13:10:05 -0400 (EDT)
Message-ID: <20130423.131005.417093102271757523.davem@davemloft.net>
References: <20130423174618.59095bd1cf999c61332d4805@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20130423174618.59095bd1cf999c61332d4805@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 23 Apr 2013 17:46:18 +1000

> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> net/netlink/af_netlink.c: In function 'netlink_frame_flush_dcache':
> net/netlink/af_netlink.c:384:40: error: 'NL_MMAP_MSG_HDRLEN' undeclared (first use in this function)
> 
> Caused by commit 9652e931e73b ("netlink: add mmap'ed netlink helper
> functions").  This needed to be build tested on an architecture that has
> ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE set to 1 (like Sparc :-)).

Sorry, my Sparcs are busy debugging other things at the moment :-)
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 23 Apr 2013 17:40:35 +1000
> Subject: [PATCH] netlink: fix typo in net/netlink/af_netlink.c
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks!
