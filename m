From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH 17/21] stmmac: drop unused Kconfig symbol
Date: Fri, 14 Oct 2011 15:25:49 +0200
Message-ID: <4E98385D.4000508@st.com>
References: <1318595432.6132.76.camel@x61.thuisdomein>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1318595432.6132.76.camel@x61.thuisdomein>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Paul

IIRC, I had posted a patch to do this long time ago.
In any case, the dual mac Kconfig is not useful and it can be removed.

Acked-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>

On 10/14/2011 2:30 PM, Paul Bolle wrote:
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
>  drivers/net/stmmac/Kconfig |    9 ---------
>  1 files changed, 0 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/stmmac/Kconfig b/drivers/net/stmmac/Kconfig
> index 7df7df4..9e37a9a 100644
> --- a/drivers/net/stmmac/Kconfig
> +++ b/drivers/net/stmmac/Kconfig
> @@ -20,15 +20,6 @@ config STMMAC_DA
>  	  By default, the DMA arbitration scheme is based on Round-robin
>  	  (rx:tx priority is 1:1).
>  
> -config STMMAC_DUAL_MAC
> -	bool "STMMAC: dual mac support (EXPERIMENTAL)"
> -	default n
> -        depends on EXPERIMENTAL && STMMAC_ETH && !STMMAC_TIMER
> -	help
> -	  Some ST SoCs (for example the stx7141 and stx7200c2) have two
> -	  Ethernet Controllers. This option turns on the second Ethernet
> -	  device on this kind of platforms.
> -
>  config STMMAC_TIMER
>  	bool "STMMAC Timer optimisation"
>  	default n
