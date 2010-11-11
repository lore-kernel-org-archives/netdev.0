From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 01/10] cxgb4vf: minor comment/symbolic name cleanup.
Date: Wed, 10 Nov 2010 19:19:38 -0800
Message-ID: <1289445578.15905.173.camel@Joe-Laptop>
References: <450C6E98-D0D9-42A6-9F15-4DB98647DB04@chelsio.com>
	 <1289441052-4925-1-git-send-email-leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Casey Leedom <leedom@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4965 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932104Ab0KKDTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Nov 2010 22:19:39 -0500
In-Reply-To: <1289441052-4925-1-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-11-10 at 18:04 -0800, Casey Leedom wrote:
> Minor cleanup of comments and symbolic constant names for clarity.
> diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
> index 6de5e2e..f5259a1 100644
> --- a/drivers/net/cxgb4vf/cxgb4vf_main.c
> +++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
> @@ -280,7 +280,7 @@ static void name_msix_vecs(struct adapter *adapter)
>  		const struct port_info *pi = netdev_priv(dev);
>  		int qs, msi;
>  
> -		for (qs = 0, msi = MSIX_NIQFLINT;
> +		for (qs = 0, msi = MSIX_IQFLINT;
>  		     qs < pi->nqsets;
>  		     qs++, msi++) {

This for now fits on a single line.

> diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
> index ea1c123..2180181 100644
> --- a/drivers/net/cxgb4vf/t4vf_hw.c
> +++ b/drivers/net/cxgb4vf/t4vf_hw.c
> @@ -1257,7 +1257,7 @@ int t4vf_eth_eq_free(struct adapter *adapter, unsigned int eqid)
>   */
>  int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
> -	struct fw_cmd_hdr *cmd_hdr = (struct fw_cmd_hdr *)rpl;
> +	const struct fw_cmd_hdr *cmd_hdr = (const struct fw_cmd_hdr *)rpl;
> @@ -1265,7 +1265,7 @@ int t4vf_handle_fw_rpl(struct adapter *adapter, const __be64 *rpl)
> -		const struct fw_port_cmd *port_cmd = (void *)rpl;
> +		const struct fw_port_cmd *port_cmd = (const void *)rpl;

might be better to have a consistent casting style.
1st uses a direct cast, 2nd an implicit one.

