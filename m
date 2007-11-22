From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] SO_NO_CHECK for IPv6
Date: Thu, 22 Nov 2007 10:34:03 +0800
Message-ID: <20071122023403.GA3409@gondor.apana.org.au>
References: <20071121124532.GA17263@havoc.gtf.org> <20071121.222051.94402865.yoshfuji@linux-ipv6.org> <4744CAA4.50102@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3123 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750905AbXKVCe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 21:34:29 -0500
Content-Disposition: inline
In-Reply-To: <4744CAA4.50102@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 21, 2007 at 07:17:40PM -0500, Jeff Garzik wrote:
>
> For those interested, I am dealing with a UDP app that already does very 
> strong checksumming and encryption, so additional software checksumming 
> at the lower layers is quite simply a waste of CPU cycles.  Hardware 
> checksumming is fine, as long as its "free."

No matter how strong your underlying checksumming is it's not
going to protect the IPv6 header is it :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
