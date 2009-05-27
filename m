From: Benjamin LaHaise <ben.lahaise@neterion.com>
Subject: Re: [0/14] GRO: Lots of microoptimisations
Date: Wed, 27 May 2009 13:52:23 -0400
Message-ID: <20090527175223.GB7804@neterion.com>
References: <20090527044539.GA32372@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 142-46-210.147.tel-ott.com ([142.46.210.147]:6605 "EHLO
	carlsberg.s2io.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S933743AbZE0S0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 14:26:36 -0400
Content-Disposition: inline
In-Reply-To: <20090527044539.GA32372@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Herbert,

On Wed, May 27, 2009 at 02:45:39PM +1000, Herbert Xu wrote:
> Hi Dave:
> 
> This series of patches brings GRO performance to within 1% of LRO
> on the slow machine that I was testing.  I can overtake LRO by
> deleting the IP checksum test and the Ethernet header test from
> GRO, which LRO doesn't do anyway, but that's not very nice :)
> 
> I'm still looking at other optimisations as time allows.

A few questions for you: I've been looking a bit into potential GRO 
optimisations that are possible with the vxge driver.  At least from my 
existing testing on a P4 Xeon, it seems that doing packet rx via 
napi_gro_receive() was a bit slower.  I'll retest with these changes 
of yours.  What platform have your tests been run on?  Also, do you have 
any notes/ideas on how best to make use of the GRO functionality within 
the kernel?  I'm hoping it's possible to make use of a few of the hardware 
hints to improve fast path performance.

	-ben
