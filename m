From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 3/9] Removed bogus 'fall-thru' comments
Date: Wed, 7 May 2008 23:30:08 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805072328570.23091@wrl-59.cs.helsinki.fi>
References: <20080507114121.GL2217@solarflare.com> <20080507115657.GO2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@vger.kernel.org>,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35749 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133AbYEGUaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 16:30:12 -0400
In-Reply-To: <20080507115657.GO2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 7 May 2008, Ben Hutchings wrote:

> Fall-through is expected outside a switch statement.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/falcon.c |    2 --
>  drivers/net/sfc/rx.c     |    1 -
>  2 files changed, 0 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
> index 46db549..9cac344 100644
> --- a/drivers/net/sfc/falcon.c
> +++ b/drivers/net/sfc/falcon.c
> @@ -2468,14 +2468,12 @@ int falcon_probe_nic(struct efx_nic *efx)
>   fail5:
>  	falcon_free_buffer(efx, &efx->irq_status);
>   fail4:
> -	/* fall-thru */
>   fail3:
>  	if (nic_data->pci_dev2) {
>  		pci_dev_put(nic_data->pci_dev2);
>  		nic_data->pci_dev2 = NULL;
>  	}
>   fail2:
> -	/* fall-thru */
>   fail1:
>  	kfree(efx->nic_data);
>  	return rc;

Is there really any point in keeping those extra goto targets? I'd suggest 
that you simply eliminate the extra ones completely.


-- 
 i.
