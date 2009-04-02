From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2 V3] kaweth: Fix locking to be SMP-safe
Date: Thu, 2 Apr 2009 18:02:23 +0800
Message-ID: <20090402100223.GA30905@gondor.apana.org.au>
References: <49d3881d.7EinO6dA2s6BnVTa%Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, oliver@neukum.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53492 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755361AbZDBKCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 06:02:36 -0400
Content-Disposition: inline
In-Reply-To: <49d3881d.7EinO6dA2s6BnVTa%Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Larry Finger <Larry.Finger@lwfinger.net> wrote:
>
> @@ -796,7 +795,7 @@ static int kaweth_start_xmit(struct sk_b
> 
>        int res;
> 
> -       spin_lock(&kaweth->device_lock);
> +       spin_lock_irq(&kaweth->device_lock);

Should be irqsave unless you don't expect to be called via netpoll.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
