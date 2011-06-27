From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH] NET: TC35815: Only build driver on Toshiba eval boards.
Date: Mon, 27 Jun 2011 21:57:47 +0900 (JST)
Message-ID: <20110627.215747.208961032.anemo@mba.ocn.ne.jp>
References: <20110625165409.GA1760@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-mips@linux-mips.org
To: ralf@linux-mips.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <20110625165409.GA1760@linux-mips.org>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-Id: netdev.vger.kernel.org

On Sat, 25 Jun 2011 17:54:09 +0100, Ralf Baechle <ralf@linux-mips.org> wrote:
> That's the only place where the TC35815 is known to be used.
> 
>   Ralf
> 
>  drivers/net/Kconfig |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index be25e92..2b4ebfb 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -1516,7 +1516,8 @@ config CS89x0_NONISA_IRQ
>  
>  config TC35815
>  	tristate "TOSHIBA TC35815 Ethernet support"
> -	depends on NET_PCI && PCI && MIPS
> +	depends on NET_PCI && PCI && MACH_TXX9
> +	default y
>  	select PHYLIB
>  
>  config E100

Yes, OK for me.

Acked-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
