From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] net: fec: Add "phy-reset-active-low" property to DT
Date: Mon, 8 Feb 2016 22:48:57 +0100
Message-ID: <20160208214857.GA13673@lunn.ch>
References: <1454962873-1941-1-git-send-email-bernhard@bwalle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fabio.estevam-KZfg59tc24xl57MIdRCFDg@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bernhard Walle <bernhard-X9USDgGjgfuzQB+pC5nmwQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1454962873-1941-1-git-send-email-bernhard-X9USDgGjgfuzQB+pC5nmwQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 08, 2016 at 09:21:13PM +0100, Bernhard Walle wrote:
> We need that for a custom hardware that needs the reverse reset
> sequence.
> 
> Signed-off-by: Bernhard Walle <bernhard-X9USDgGjgfuzQB+pC5nmwQ@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/fsl-fec.txt | 3 +++
>  drivers/net/ethernet/freescale/fec_main.c         | 8 ++++++--
>  2 files changed, 9 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt b/Documentation/devicetree/bindings/net/fsl-fec.txt
> index a9eb611..a4799ff 100644
> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -12,6 +12,9 @@ Optional properties:
>    only if property "phy-reset-gpios" is available.  Missing the property
>    will have the duration be 1 millisecond.  Numbers greater than 1000 are
>    invalid and 1 millisecond will be used instead.
> +- phy-reset-active-low : If present then the reset sequence using the GPIO
> +  specified in the "phy-reset-gpios" property is reversed (H=reset state,
> +  L=operation state).

Hi Bernhard

Maybe at the same time add a comment to phy-reset-gpios that the flags
part is ignored, see the none standard phy-reset-active-low property
instead.

	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
