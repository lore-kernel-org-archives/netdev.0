From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: + oops-in-drivers-net-shaperc.patch added to -mm tree
Date: Sat, 27 Jan 2007 11:45:05 +1100
Message-ID: <E1HAbgn-00039h-00@gondolin.me.apana.org.au>
References: <20070125.193128.39155864.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, akpm@osdl.org, deweerdt@free.fr,
	netdev@vger.kernel.org, frederik.deweerdt@gmail.com,
	shemminger@osdl.org
To: davem@davemloft.net (David Miller)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4339 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751816AbXA0ApO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jan 2007 19:45:14 -0500
In-Reply-To: <20070125.193128.39155864.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> 
> Shaper is actually OK.  None of these hardware header callbacks
> should be invoked if the device is down.  Yet, this is what is
> accidently being allowed in the AF_PACKET socket layer.

Hmm, what if the device goes down after the check?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
