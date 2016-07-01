From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V6 1/1] net: ethernet: Add TSE PCS support to
 dwmac-socfpga
Date: Thu, 30 Jun 2016 20:38:47 -0500
Message-ID: <20160701013847.GA25538@rob-hp-laptop>
References: <1467191413-16715-1-git-send-email-thloh@altera.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mark.rutland-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
	alexandre.torgue-qxv4g6HH51o@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	preid-qgqNFa1JUf/o2iN0hyhwsIdd74u8MsAO@public.gmane.org, dinguyen-yzvPICuk2ABMcg4IHK0kFoH6Mc4MB0Vx@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, thloh85-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cnphoon-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org
To: thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1467191413-16715-1-git-send-email-thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 29, 2016 at 02:10:13AM -0700, thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org wrote:
> From: Tien Hock Loh <thloh-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org>
> 
> This adds support for TSE PCS that uses SGMII adapter when the phy-mode of
> the dwmac is set to sgmii.
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
> v4:
> - Reset SGMII adapter on speed change
> - Do not enable SGMII adapter if speed is not supported
> - On init, if PCS reset fails, do not enable adapter
> v5:
> - Fixed devicetree binding property name using _ instead of -
> v6:
> - Fixed a problem where driver build broken if driver is set as module
> ---
>  .../devicetree/bindings/net/socfpga-dwmac.txt      |  19 ++

Acked-by: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

>  drivers/net/ethernet/stmicro/stmmac/Makefile       |   3 +-
>  drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c | 276 +++++++++++++++++++++
>  drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h |  36 +++
>  .../net/ethernet/stmicro/stmmac/dwmac-socfpga.c    | 141 +++++++++--
>  5 files changed, 453 insertions(+), 22 deletions(-)
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.c
>  create mode 100644 drivers/net/ethernet/stmicro/stmmac/altr_tse_pcs.h
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
