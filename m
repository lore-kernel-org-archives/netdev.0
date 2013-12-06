From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next 1/3] xfrm: check user specified spi for IPComp
Date: Fri, 6 Dec 2013 12:44:27 +0100
Message-ID: <20131206114427.GH31491@secunet.com>
References: <1385607161-27597-1-git-send-email-fan.du@windriver.com>
 <1385607161-27597-2-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53150 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754507Ab3LFLo3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Dec 2013 06:44:29 -0500
Content-Disposition: inline
In-Reply-To: <1385607161-27597-2-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 28, 2013 at 10:52:39AM +0800, Fan Du wrote:
> 
> diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
> index f964d4c..52efe71 100644
> --- a/net/xfrm/xfrm_user.c
> +++ b/net/xfrm/xfrm_user.c
> @@ -209,7 +209,8 @@ static int verify_newsa_info(struct xfrm_usersa_info *p,
>  		    attrs[XFRMA_ALG_AUTH]	||
>  		    attrs[XFRMA_ALG_AUTH_TRUNC]	||
>  		    attrs[XFRMA_ALG_CRYPT]	||
> -		    attrs[XFRMA_TFCPAD])
> +		    attrs[XFRMA_TFCPAD] ||
> +			(ntohl(p->id.spi) >= 0x10000))

Please align the above line to the rest of this block.
