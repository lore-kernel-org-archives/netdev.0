From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: raw: revert unrelated change
Date: Tue, 25 Sep 2012 03:11:53 -0400 (EDT)
Message-ID: <20120925.031153.2084805663532004378.davem@davemloft.net>
References: <20120925.011343.1495275645575636949.davem@davemloft.net>
	<1348550602.26828.1918.camel@edumazet-glaptop>
	<1348554076.26828.1990.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1348554076.26828.1990.camel@edumazet-glaptop>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Sep 2012 08:21:16 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 5640f7685831 ("net: use a per task frag allocator")
> accidentally contained an unrelated change to net/ipv4/raw.c,
> later committed (without the pr_err() debugging bits) in
> net tree as commit ab43ed8b749 (ipv4: raw: fix icmp_filter())
> 
> This patch reverts this glitch, noticed by Stephen Rothwell.
> 
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
