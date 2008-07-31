From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 31 Jul 2008 11:54:10 +0800
Message-ID: <20080731035410.GA4893@gondor.apana.org.au>
References: <20080730235004.GC21999@xi.wantstofly.org> <20080730.165621.211366535.davem@davemloft.net> <20080731004123.GB22826@xi.wantstofly.org> <20080730.181047.39922732.davem@davemloft.net> <20080731014506.GA23402@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48213 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750910AbYGaDyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 23:54:20 -0400
Content-Disposition: inline
In-Reply-To: <20080731014506.GA23402@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 31, 2008 at 03:45:06AM +0200, Lennert Buytenhek wrote:
>
> +	return (caps & NETIF_F_SG) &&
> +		 (((type == SKB_GSO_TCPV4 || type == SKB_GSO_UDP) &&

Nobody has written software UFO yet.  Let's just stick TCP for
now.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
