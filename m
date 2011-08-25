From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH] stmmac: remove the STBus bridge setting from the GMAC
 code
Date: Thu, 25 Aug 2011 10:01:46 +0200
Message-ID: <4E56016A.8060709@st.com>
References: <1314021507-26955-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: ML netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog109.obsmtp.com ([207.126.144.127]:44451 "EHLO
	eu1sys200aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751164Ab1HYICG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2011 04:02:06 -0400
In-Reply-To: <1314021507-26955-1-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello David
you can discard this because I'm resending it in a bundle of patches to
update the whole driver to the Aug_2011 version.

Peppe

On 8/22/2011 3:58 PM, Giuseppe CAVALLARO wrote:
> This patch removes a piece of code (actually commented)
> only useful for some ST platforms in the past.
> 
> This kind of setting now can be done by using the platform
> callbacks provided in linux/stmmac.h (see the stmmac.txt for
> further details).
> 
> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
> ---
>  drivers/net/stmmac/dwmac1000_core.c |    3 ---
>  1 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/stmmac/dwmac1000_core.c b/drivers/net/stmmac/dwmac1000_core.c
> index 0f63b3c..eea184a 100644
> --- a/drivers/net/stmmac/dwmac1000_core.c
> +++ b/drivers/net/stmmac/dwmac1000_core.c
> @@ -37,9 +37,6 @@ static void dwmac1000_core_init(void __iomem *ioaddr)
>  	value |= GMAC_CORE_INIT;
>  	writel(value, ioaddr + GMAC_CONTROL);
>  
> -	/* STBus Bridge Configuration */
> -	/*writel(0xc5608, ioaddr + 0x00007000);*/
> -
>  	/* Freeze MMC counters */
>  	writel(0x8, ioaddr + GMAC_MMC_CTRL);
>  	/* Mask GMAC interrupts */
