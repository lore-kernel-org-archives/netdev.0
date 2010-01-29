From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] [PATCH] Optimize TCP sendmsg in favour of fast devices?
Date: Fri, 29 Jan 2010 22:07:20 +1300
Message-ID: <20100129090720.GE23140@gondor.apana.org.au>
References: <20100121.012520.254679483.davem@davemloft.net> <20100121094157.GA15262@gondor.apana.org.au> <OF7EA723DA.DC2FF4FC-ON652576B8.002064CB-652576B8.00267739@LocalDomain> <OFC641141C.812873FC-ON652576B8.003216B6-652576B8.003440CC@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47723 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752151Ab0A2JRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 04:17:20 -0500
Content-Disposition: inline
In-Reply-To: <OFC641141C.812873FC-ON652576B8.003216B6-652576B8.003440CC@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 27, 2010 at 03:12:48PM +0530, Krishna Kumar2 wrote:
> 
> I should have mentioned this too - if I unset F_SG in the
> cxgb3 driver and nothing else, ethtool -k still shows GSO
> is set, and tcpdump shows max packet size is 1448. If I
> additionally set GSO in driver, then ethtool still has the
> same output, but tcpdump shows max packet size of 65160.

This sounds like a bug.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
