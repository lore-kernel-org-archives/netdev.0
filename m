From: David Miller <davem@davemloft.net>
Subject: Re: rhashtable: Use __vmalloc with GFP_ATOMIC for table allocation
Date: Fri, 04 Dec 2015 16:53:34 -0500 (EST)
Message-ID: <20151204.165334.1119277452308794437.davem@davemloft.net>
References: <20151203125117.GB5505@gondor.apana.org.au>
	<1449158919.6379.27.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151204143956.GA17471@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, phil@nwl.cc, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tgraf@suug.ch,
	fengguang.wu@intel.com, wfg@linux.intel.com, lkp@01.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151204143956.GA17471@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 4 Dec 2015 22:39:56 +0800

> When an rhashtable user pounds rhashtable hard with back-to-back
> insertions we may end up growing the table in GFP_ATOMIC context.
> Unfortunately when the table reaches a certain size this often
> fails because we don't have enough physically contiguous pages
> to hold the new table.
> 
> Eric Dumazet suggested (and in fact wrote this patch) using
> __vmalloc instead which can be used in GFP_ATOMIC context.
> 
> Reported-by: Phil Sutter <phil@nwl.cc>
> Suggested-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
