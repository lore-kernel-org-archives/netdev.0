From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 04/10] bnxt_en: Refactor bnxt_hwrm_set_coal().
Date: Thu, 25 Feb 2016 11:32:37 -0500 (EST)
Message-ID: <20160225.113237.332720242469554990.davem@davemloft.net>
References: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
	<1456388374-1440-5-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933134AbcBYQci (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 11:32:38 -0500
In-Reply-To: <1456388374-1440-5-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Thu, 25 Feb 2016 03:19:28 -0500

> Add a function to set all the coalescing parameters.  The function can
> be used later to set both rx and tx coalescing parameters.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>
> ---
>  drivers/net/ethernet/broadcom/bnxt/bnxt.c | 26 +++++++++++++++++---------
>  1 file changed, 17 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> index a7103b5..b87b367 100644
> --- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> +++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
> @@ -3521,6 +3521,21 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
>  	}
>  }
>  
> +static void bnxt_hwrm_set_coal_params(
> +	struct bnxt *bp, u32 max_bufs, u32 buf_tmrs, u16 flags,
> +	struct hwrm_ring_cmpl_ring_cfg_aggint_params_input *req)

Don't format arguments like this, it's insanely ugly.  You can and
should fit the first few arguments on the line that opens the argument
list.
