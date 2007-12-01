From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 2/3][IPV4] Unify and cleanup calls to devinet_sysctl_register
Date: Sun, 2 Dec 2007 00:20:00 +1100
Message-ID: <20071201132000.GG15910@gondor.apana.org.au>
References: <475055F2.4090509@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3532 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751938AbXLANUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 08:20:02 -0500
Content-Disposition: inline
In-Reply-To: <475055F2.4090509@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2007 at 09:26:58PM +0300, Pavel Emelyanov wrote:
> 
> Besides, the inet_device is passed to this function, but
> it is not needed there at all - just the device name and
> ifindex are required.

But it is called devinet_* so an in_dev kind of makes sense :)

>  #ifdef CONFIG_SYSCTL
> -	devinet_sysctl_register(in_dev, &in_dev->cnf);
> +	devinet_sysctl_register(dev, &in_dev->cnf);

How about just giving it in_dev instead?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
