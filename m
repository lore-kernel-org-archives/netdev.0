From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: bridge: Eliminate unnecessary forward delay
Date: Tue, 5 Aug 2008 10:12:40 +0800
Message-ID: <20080805021240.GA18159@gondor.apana.org.au>
References: <20080804170439.GA13546@gondor.apana.org.au> <20080804103534.6b7896d9@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52390 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751608AbYHECMp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 22:12:45 -0400
Content-Disposition: inline
In-Reply-To: <20080804103534.6b7896d9@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 04, 2008 at 10:35:34AM -0700, Stephen Hemminger wrote:
>
> Same again, this time compile tested...
> 
> --- a/net/bridge/br_stp.c	2008-08-04 10:20:21.000000000 -0700
> +++ b/net/bridge/br_stp.c	2008-08-04 10:29:26.000000000 -0700
> @@ -368,14 +368,25 @@ static void br_make_blocking(struct net_
>  /* called under bridge lock */
>  static void br_make_forwarding(struct net_bridge_port *p)
>  {
> -	if (p->state == BR_STATE_BLOCKING) {

Is it safe to remove this check, especially if the forward delay
is non-zero?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
