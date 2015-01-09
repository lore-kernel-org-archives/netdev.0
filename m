From: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
Subject: Re: [PATCH] ethernet: atheros: Add nss-gmac driver
Date: Fri, 9 Jan 2015 13:50:45 +0000
Message-ID: <20150109135045.GE12942@leverpostej>
References: <y>
 <1420754626-30121-1-git-send-email-wstephen@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <jcliburn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Wang <wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1420754626-30121-1-git-send-email-wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Jan 08, 2015 at 10:03:46PM +0000, Stephen Wang wrote:
> This driver adds support for the internal GMACs on IPQ806x SoCs.
> It supports the device-tree and will register up to 4 ethernet
> interfaces.
> 
> Signed-off-by: Stephen Wang <wstephen-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> ---
>  drivers/net/ethernet/atheros/Kconfig               |   10 +
>  drivers/net/ethernet/atheros/Makefile              |    1 +
>  drivers/net/ethernet/atheros/nss-gmac/LICENSE.txt  |   14 +
>  drivers/net/ethernet/atheros/nss-gmac/Makefile     |   19 +
>  .../atheros/nss-gmac/exports/nss_gmac_api_if.h     |  126 ++
>  .../atheros/nss-gmac/include/msm_nss_gmac.h        |  338 ++++
>  .../atheros/nss-gmac/include/msm_nss_macsec.h      |   73 +
>  .../atheros/nss-gmac/include/nss_gmac_clocks.h     |  100 +
>  .../atheros/nss-gmac/include/nss_gmac_dev.h        | 2136 ++++++++++++++++++++
>  .../nss-gmac/include/nss_gmac_network_interface.h  |   63 +
>  .../net/ethernet/atheros/nss-gmac/nss_gmac_ctrl.c  | 1210 +++++++++++
>  .../net/ethernet/atheros/nss-gmac/nss_gmac_dev.c   | 1963 ++++++++++++++++++
>  .../ethernet/atheros/nss-gmac/nss_gmac_ethtool.c   |  526 +++++
>  .../net/ethernet/atheros/nss-gmac/nss_gmac_init.c  | 1131 +++++++++++
>  .../ethernet/atheros/nss-gmac/nss_gmac_mdiobus.c   |  187 ++
>  .../atheros/nss-gmac/nss_gmac_tx_rx_offload.c      | 1175 +++++++++++

Device tree bindings _must_ be documented, yet this standalone patch
adds nothing to Documentation/devicetree/bindings per the diffstat
above. So trivial NAK until there's a patch documenting that.

See Documentation/devicetree/bindings/submitting-patches.txt 

Thanks,
Mark.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
