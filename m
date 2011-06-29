From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Wed, 29 Jun 2011 02:58:21 -0700 (PDT)
Message-ID: <20110629.025821.232474717396156253.davem@davemloft.net>
References: <BANLkTin+iCahNVJGKc-_26pb9zEERTc8_A@mail.gmail.com>
	<20110627152927.943c34dc.sfr@canb.auug.org.au>
	<20110629160901.2d3cd6da.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110629160901.2d3cd6da.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 29 Jun 2011 16:09:01 +1000

> Again, this has taken some time to fix ...
> 
> Dave, I think you have raised my expectations too far ;-)

Sorry.  I try to give the offender time to fix the build failure
himself, but as you saw this time that didn't work out.

To be honest I'm going to be quite reluctant to apply these kinds of
header removal patches in the future if this is how responsive the
patch submitter is going to be to build fallout. :-/

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 29 Jun 2011 16:03:18 +1000
> Subject: [PATCH] net: include dma-mapping.h for dma_map_single etc
> 
> fixes thses build errors:
 ...
> Caused by commit commit b7f080cfe223 ("net: remove mm.h inclusion from
> netdevice.h").
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks!
