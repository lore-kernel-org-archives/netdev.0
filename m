From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 09 Mar 2015 23:43:29 -0400 (EDT)
Message-ID: <20150309.234329.425011226766680524.davem@davemloft.net>
References: <20150310120842.6dfa6c2b@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, joshc@ni.com,
	boris.brezillon@free-electrons.com, cyrille.pitchen@atmel.com
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150310120842.6dfa6c2b@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 10 Mar 2015 12:08:42 +1100

> Today's linux-next merge of the net-next tree got a conflict in
> drivers/net/ethernet/cadence/macb.c between commit 0b2eb3e9bc73 ("net:
> macb: constify macb configuration data") from the net tree and commits
> a848748959d5 ("net: macb: remove #if defined(CONFIG_ARCH_AT91)
> sections") and 421d9df0628b ("net/macb: merge at91_ether driver into
> macb driver") from the net-next tree.
> 
> I fixed it up (I think - see below) and can carry the fix as necessary
> (no action is required).

Thanks Stephen, I'm merging net into net-next right now and will resolve
this similarly.

Thanks!
