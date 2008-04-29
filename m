From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] virtio: wean net driver off NETDEV_TX_BUSY
Date: Tue, 29 Apr 2008 13:06:16 +0800
Message-ID: <20080429050616.GA17840@gondor.apana.org.au>
References: <200804290116.05951.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34819 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755151AbYD2FG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 01:06:26 -0400
Content-Disposition: inline
In-Reply-To: <200804290116.05951.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 29, 2008 at 01:16:05AM +1000, Rusty Russell wrote:
>
> +	/* If we has a buffer left over from last time, send it now. */
> +	if (vi->last_xmit_skb) {
> +		if (xmit_skb(vi, vi->last_xmit_skb) != 0) {
> +			/* Drop this skb: we only queue one. */
> +			kfree_skb(skb);
> +			goto stop_queue;

We should increment the drop counter here.

Otherwise these patches all look good to me.

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
