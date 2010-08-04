From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Yet another bridge netfilter crash
Date: Thu, 5 Aug 2010 00:41:19 +0800
Message-ID: <20100804164119.GA6256@gondor.apana.org.au>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net> <20100723150041.GA7301@gondor.apana.org.au> <4C49B296.10009@trash.net> <20100723152609.GA7576@gondor.apana.org.au> <4C5995C2.1010909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39537 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755831Ab0HDQlZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Aug 2010 12:41:25 -0400
Content-Disposition: inline
In-Reply-To: <4C5995C2.1010909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 04, 2010 at 06:30:58PM +0200, Patrick McHardy wrote:
>
> We could perform a new device lookup on reassembly as we do
> when expiring a fragment queue, but we probably shouldn't even
> be reassembling fragments from different bridges. One way to
> avoid this would be to automatically assign each bridge device
> to a different conntrack zone, but conntrack zones are limited
> to 2^16 and this might also have other unwanted side-effects.
> 
> Until we come up with something better the best fix seems to
> be to perform the device lookup based on the iif.

I don't think we can as the iif will point to the bridge device.
The physindev contains the original physical device where the
packet came in.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
