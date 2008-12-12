From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 24/33] sfc: Fix format arguments for warning about
	MSI-X allocation
Date: Fri, 12 Dec 2008 20:34:47 +0000
Message-ID: <1229114087.3051.17.camel@achroite>
References: <cover.1229085672.git.bhutchings@solarflare.com>
	 <20081212125637.GX10372@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:41092 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752555AbYLLUew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 15:34:52 -0500
In-Reply-To: <20081212125637.GX10372@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-12 at 12:56 +0000, Ben Hutchings wrote:
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/efx.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
> index b99ccfb..ce1c7d3 100644
> --- a/drivers/net/sfc/efx.c
> +++ b/drivers/net/sfc/efx.c
> @@ -899,7 +899,7 @@ static void efx_probe_interrupts(struct efx_nic *efx)
>  		rc = pci_enable_msix(efx->pci_dev, xentries, wanted_ints);
>  		if (rc > 0) {
>  			EFX_ERR(efx, "WARNING: Insufficient MSI-X vectors"
> -				" available (%d < %d).\n", wanted_ints, rc);
> +				" available (%d < %d).\n", rc, wanted_ints);
>  			EFX_ERR(efx, "WARNING: Performance may be reduced.\n");
>  			EFX_BUG_ON_PARANOID(rc >= wanted_ints);
>  			wanted_ints = rc;

I thought this warning was already present, but it is actually
introduced by patch 10/33.  There's no point in introducing it wrongly,
so please combine the two.  Or I can post the combined patch myself.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

