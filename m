From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: Re: [PATCH 2/2] liquidio: mark expected switch fall-through in
 octeon_destroy_resources
Date: Wed, 18 Oct 2017 10:53:57 -0700
Message-ID: <20171018175357.GA14232@felix-thinkpad.cavium.com>
References: <20171017185920.GA16976@embeddedor.com>
 <20171017190145.GA17015@embeddedor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Gustavo A. R. Silva" <garsilva@embeddedor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0071.outbound.protection.outlook.com ([104.47.36.71]:45600
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750724AbdJRRyC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 13:54:02 -0400
Content-Disposition: inline
In-Reply-To: <20171017190145.GA17015@embeddedor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 17, 2017 at 02:01:45PM -0500, Gustavo A. R. Silva wrote:
> In preparation to enabling -Wimplicit-fallthrough, mark switch cases
> where we are expecting to fall through.
> 
> Signed-off-by: Gustavo A. R. Silva <garsilva@embeddedor.com>
> ---
> This code was tested by compilation only (GCC 7.2.0 was used).
> Please, verify if the actual intention of the code is to fall through.
> 
>  drivers/net/ethernet/cavium/liquidio/lio_vf_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> index e4a112c..4c3b568 100644
> --- a/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> +++ b/drivers/net/ethernet/cavium/liquidio/lio_vf_main.c
> @@ -747,7 +747,7 @@ static void octeon_destroy_resources(struct octeon_device *oct)
>  
>  		if (lio_wait_for_oq_pkts(oct))
>  			dev_err(&oct->pci_dev->dev, "OQ had pending packets\n");
> -
> +		/* fall through */
>  	case OCT_DEV_INTR_SET_DONE:
>  		/* Disable interrupts  */
>  		oct->fn_list.disable_interrupt(oct, OCTEON_ALL_INTR);
> -- 
> 2.7.4
> 

Acked-by: Felix Manlunas <felix.manlunas@cavium.com>
