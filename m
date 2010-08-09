From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Yet another bridge netfilter crash
Date: Mon, 9 Aug 2010 17:42:54 -0400
Message-ID: <20100809214254.GA23824@gondor.apana.org.au>
References: <20100723134208.GA6655@gondor.apana.org.au> <4C49A4C6.4070503@trash.net> <20100723150041.GA7301@gondor.apana.org.au> <4C49B296.10009@trash.net> <20100723152609.GA7576@gondor.apana.org.au> <4C5995C2.1010909@trash.net> <20100804164119.GA6256@gondor.apana.org.au> <4C599A6A.6050202@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:46451 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab0HIVnC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Aug 2010 17:43:02 -0400
Content-Disposition: inline
In-Reply-To: <4C599A6A.6050202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 04, 2010 at 06:50:50PM +0200, Patrick McHardy wrote:
.
> >> Until we come up with something better the best fix seems to
> >> be to perform the device lookup based on the iif.
> > 
> > I don't think we can as the iif will point to the bridge device.
> > The physindev contains the original physical device where the
> > packet came in.
> 
> If it originally points to the bridge device, there doesn't
> seem anything wrong with the device pointing to the bridge
> device after reassembly. Am I missing something?

It's there so that netfilter rules can filter based on the original
inbound interface.

If you set it to the bridge then those rules won't work anymore.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
