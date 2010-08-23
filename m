From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Sun, 22 Aug 2010 20:31:40 -0700 (PDT)
Message-ID: <20100822.203140.15257163.davem@davemloft.net>
References: <20100823132734.ffc076ae.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, baronchon@n7mm.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100823132734.ffc076ae.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 23 Aug 2010 13:27:34 +1000

> Subject: [PATCH] net/sched: need to include net/ip6_checksum.h
> 
> for the declararion of csum_ipv6_magic.
> 
> Fixes this build error on PowerPC (at least):
> 
> net/sched/act_csum.c: In function 'tcf_csum_ipv6_icmp':
> net/sched/act_csum.c:178: error: implicit declaration of function 'csum_ipv6_magic'
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Oh, if I only had a dollar for every time we've had to fix up
something like this :-)

Applied, thanks!
