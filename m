From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: Re: [patch -next] bnx2x: remove bogus check
Date: Tue, 21 Dec 2010 15:48:36 +0200
Message-ID: <1292939316.21210.7084.camel@lb-tlvb-eilong.il.broadcom.com>
References: <20101221070401.GF1936@bicker>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: "Dan Carpenter" <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3379 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751280Ab0LUNsx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Dec 2010 08:48:53 -0500
In-Reply-To: <20101221070401.GF1936@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-20 at 23:04 -0800, Dan Carpenter wrote:
> We dereferenced params on the line before so it's too late to check if
> params is NULL.  In fact, params can never be NULL and strict_cos is
> either 0 or 1 so that part of the check is bogus too.  Let's remove it.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Thanks Dan!

Acked-by: Eilon Greenstein <eilong@broadcom.com>

> 
> diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
> index 97cbee2..43b0de2 100644
> --- a/drivers/net/bnx2x/bnx2x_link.c
> +++ b/drivers/net/bnx2x/bnx2x_link.c
> @@ -354,9 +354,6 @@ u8 bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos)
>  	struct bnx2x *bp = params->bp;
>  	u32 val	= 0;
>  
> -	if ((1 < strict_cos) && (NULL == params))
> -		return -EINVAL;
> -
>  	DP(NETIF_MSG_LINK, "ETS enabled strict configuration\n");
>  	/**
>  	 * Bitmap of 5bits length. Each bit specifies whether the entry behaves
> 




