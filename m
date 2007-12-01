From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-2.6.25 2/3][IPV6] Unify and cleanup calls to addrconf_sysctl_register
Date: Sun, 2 Dec 2007 00:24:22 +1100
Message-ID: <20071201132422.GH15910@gondor.apana.org.au>
References: <47505C7B.7070905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3564 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751060AbXLANY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 08:24:28 -0500
Content-Disposition: inline
In-Reply-To: <47505C7B.7070905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 30, 2007 at 09:54:51PM +0300, Pavel Emelyanov wrote:
>
> +static void addrconf_sysctl_register(struct inet6_dev *idev,
> +		struct ipv6_devconf *p)

Due to your simplification you no longer need the second argument
as it can now be derived from the first as is the case for IPv4.

So let's get rid of that while we're at it.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
