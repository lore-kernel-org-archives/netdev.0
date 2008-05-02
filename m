From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.25 crash: EIP: [<c02e2f14>] xfrm_output_resume+0x64/0x100 ss:esp 0068:c03a1e5c
Date: Fri, 02 May 2008 20:02:11 +0800
Message-ID: <E1Jrtxr-0004in-00@gondolin.me.apana.org.au>
References: <BAY103-DAV12E9E0E5107A5FCEF3F473B2D90@phx.gbl>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: pupilla@hotmail.com (Marco Berizzi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44321 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751452AbYEBMCO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 08:02:14 -0400
In-Reply-To: <BAY103-DAV12E9E0E5107A5FCEF3F473B2D90@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi <pupilla@hotmail.com> wrote:
> Just few minutes ago, another 2.6.25 crash
> with this message:
> 
> EIP: [<c028000a>] netif_rx+0x6a/0xd0 SS:ESP 0068:c039f868
> 
> http://80.204.235.230/4.jpg

OK, the xfrm_output_resume trail revealed nothing.  Combined
with this crash however, it would appear that you've got a problem
with live skbs being freed.  Unfortunately such problems are
difficult to track down.

Perhaps you could enable SLAB debugging to see if we can get
closer to the culprit? Alternatively you could try a git bisection.

Unless we have a way of reproducing this there isn't a lot more
that we can do I'm afraid.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
