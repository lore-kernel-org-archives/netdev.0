From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v3 1/1] net: ethernet: Add TSE PCS support to
 dwmac-socfpga
Date: Wed, 8 Jun 2016 14:52:01 -0500
Message-ID: <20160608195201.GA5838@rob-hp-laptop>
References: <1465268516-31480-1-git-send-email-thloh@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pawel.moll-5wv7dgnIgG8@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
	ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org, galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1465268516-31480-1-git-send-email-thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 06, 2016 at 08:01:56PM -0700, thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org wrote:
> From: Tien Hock Loh <thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
> 
> This adds support for TSE PCS that uses SGMII adapter when the phy-mode of
> the dwmac is set to sgmii
> 
> Signed-off-by: Tien Hock Loh <thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
> 
> ---
> v2:
> - Refactored the TSE PCS out from the dwmac-socfpga.c file
> - Added binding documentation for TSE PCS sgmii adapter
> v3:
> - Added missing license header for new source files
> - Updated tse_pcs.h include headers
> - Standardize if statements
> ---
>  .../devicetree/bindings/net/socfpga-dwmac.txt      |   4 +
>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   2 +-
>  .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 140 +++++++++--
>  drivers/net/ethernet/stmicro/stmmac/tse_pcs.c      | 261 +++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/tse_pcs.h      |  36 +++
>  5 files changed, 419 insertions(+), 24 deletions(-)
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/tse_pcs.c
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/tse_pcs.h
> 
> diff --git a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> index 3a9d679..2bc39f1 100644
> --- a/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> +++ b/Documentation/devicetree/bindings/net/socfpga-dwmac.txt
> @@ -15,6 +15,8 @@ Required properties:
>  Optional properties:
>  altr,emac-splitter: Should be the phandle to the emac splitter soft IP node if
>  		DWMAC controller is connected emac splitter.
> +phy-mode: The phy mode the ethernet operates in
> +altr,sgmii_to_sgmii_converter: phandle to the TSE SGMII converter

Use '-' rather than '_'.

With that, for the binding:

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
