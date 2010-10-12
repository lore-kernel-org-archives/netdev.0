From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] bnx2x: Fixing a typo: added a missing RSS
 enablement
Date: Tue, 12 Oct 2010 12:26:19 -0700
Message-ID: <1286911579.1117.76.camel@Joe-Laptop>
References: <1286910141.16797.23.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, vladz@broadcom.com, eilong@broadcom.com
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2793 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932349Ab0JLT0V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Oct 2010 15:26:21 -0400
In-Reply-To: <1286910141.16797.23.camel@lb-tlvb-dmitry>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-10-12 at 21:02 +0200, Dmitry Kravkov wrote:
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
> ---
>  drivers/net/bnx2x/bnx2x_main.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
> index 7a9556b..ead524b 100644
> --- a/drivers/net/bnx2x/bnx2x_main.c
> +++ b/drivers/net/bnx2x/bnx2x_main.c
> @@ -2486,6 +2486,7 @@ void bnx2x_pf_init(struct bnx2x *bp)
>  	 * if (is_eth_multi(bp))
>  	 *	flags |= FUNC_FLG_RSS;
>  	 */
> +	flags |= FUNC_FLG_RSS;
>  
>  	/* function setup */
>  	if (flags & FUNC_FLG_RSS) {

Then the "if (flags & FUNC_FLG_RSS)" test should be removed.



