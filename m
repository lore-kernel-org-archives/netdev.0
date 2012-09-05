From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Wed, 05 Sep 2012 17:46:37 -0400 (EDT)
Message-ID: <20120905.174637.1499279266416363296.davem@davemloft.net>
References: <20120905153932.eebf343364800678aecc98f2@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, kaber@trash.net
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120905153932.eebf343364800678aecc98f2@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 5 Sep 2012 15:39:32 +1000

> (I always thought IPv6 NAT was a bad idea ;-))

ROFL :)

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 5 Sep 2012 15:34:58 +1000
> Subject: [PATCH] netfilter: ipv6: using csum_ipv6_magic requires
>  net/ip6_checksum.h
> 
> Fixes this build error:
> 
> net/ipv6/netfilter/nf_nat_l3proto_ipv6.c: In function 'nf_nat_ipv6_csum_recalc':
> net/ipv6/netfilter/nf_nat_l3proto_ipv6.c:144:4: error: implicit declaration of function 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks Stephen.
