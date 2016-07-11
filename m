From: Simon Horman <simon.horman@netronome.com>
Subject: Re: linux-next: build warning after merge of the net-next tree
Date: Mon, 11 Jul 2016 17:16:57 +0900
Message-ID: <20160711081655.GA14800@penelope.isobedori.kobe.vergenet.net>
References: <20160711161311.5049ec64@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dinan Gunawardena <dinan.gunawardena@netronome.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160711161311.5049ec64@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 11, 2016 at 04:13:11PM +1000, Stephen Rothwell wrote:
> Hi all,
> 
> After merging the net-next tree, today's linux-next build (arm
> multi_v7_defconfig) produced this warning (CONFIG_MPLS is disabled):
> 
> net/ipv4/tunnel4.c: In function 'tunnel4_init':
> net/ipv4/tunnel4.c:223:1: warning: label 'err_mpls' defined but not used [-Wunused-label]
>  err_mpls:
>  ^
> 
> and the powerpc ppc64_defconfig build produced this (CONFIG_IPV6 is disabled):
> 
> net/ipv4/tunnel4.c: In function 'tunnel4_init':
> net/ipv4/tunnel4.c:226:1: warning: label 'err_ipv6' defined but not used [-Wunused-label]
>  err_ipv6:
>  ^
> 
> Introduced by commit
> 
>   8afe97e5d416 ("tunnels: support MPLS over IPv4 tunnels")

Thanks Stephen,

I have posted a fix for this.

"[PATCH net-next v2] tunnels: correct conditional build of MPLS and IPv6"
