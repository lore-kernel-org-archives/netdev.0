From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tcp: Do not apply TSO segment limit to non-TSO packets
Date: Sat, 3 Jan 2015 09:09:35 +1100
Message-ID: <20150102220935.GA28977@gondor.apana.org.au>
References: <1420223040.32621.6.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150102.153655.1853692198479011402.davem@davemloft.net>
 <20150102220107.GA28599@gondor.apana.org.au>
 <20150102.170629.1474417873101408441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, thomas.jarosch@intra2net.com,
	netdev@vger.kernel.org, edumazet@google.com,
	steffen.klassert@secunet.com, bhutchings@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:47794 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752093AbbABWJn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 17:09:43 -0500
Content-Disposition: inline
In-Reply-To: <20150102.170629.1474417873101408441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 02, 2015 at 05:06:29PM -0500, David Miller wrote:
>
> I think the rarity of PMTU events on non-VPN'd connections plays
> a part in how long it took as well.

Maybe in your neck of the woods but certainly in China I observe
loads of PMTU events without involving any VPNs at all :)

In fact even the fibre connections here use PPPOE so PMTU is
sort of unavoidable.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
