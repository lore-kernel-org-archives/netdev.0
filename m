From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [ANNOUNCE] libnetfilter_queue 1.0.1 release
Date: Mon, 2 Jan 2012 22:45:31 +0100
Message-ID: <20120102214531.GA27247@1984>
References: <20120102195845.GA26867@1984>
 <alpine.LNX.2.01.1201022221470.29809@frira.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	netfilter-announce@lists.netfilter.org, lwn@lwn.net
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1201022221470.29809@frira.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 02, 2012 at 10:22:28PM +0100, Jan Engelhardt wrote:
> On Monday 2012-01-02 20:58, Pablo Neira Ayuso wrote:
> 
> >Hi!
> >
> >The Netfilter project proudly presents:
> >
> >        libnetfilter_queue 1.0.1
> 
> In commit 390b0c0f45597c72fa93a40f4f7f9ffeec371f42
> Author: Pablo Neira Ayuso <pablo@netfilter.org>
> Date:   Mon Jan 2 20:28:45 2012 +0100
> 
>     build: bump version to 1.0.1
>     
>     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> diff --git a/src/Makefile.am b/src/Makefile.am
> index 0bd037f..bc27625 100644
> --- a/src/Makefile.am
> +++ b/src/Makefile.am
> @@ -18,7 +18,7 @@
>  # set age to 0.
>  # </snippet>
>  #
> -LIBVERSION=2:0:1
> +LIBVERSION=2:0:2
>  
>  include ${top_srcdir}/Make_global.am
>  
> 
> You wrongly changed LIBVERSION. It went from .so.1.1 to so.0.2, and that 
> just does not sound right. Perhaps you intended 2:1:1.
> 
> Or just leaving r alone, like proposed? :)

I forgot to increment current, Florian Westphal added some new
interfaces. I'll fix this, sorry.
