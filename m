From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 10:17:58 +0800
Message-ID: <20131108021758.GA13467@gondor.apana.org.au>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
 <20131107.161755.355597965034457889.davem@davemloft.net>
 <20131107213111.GA6885@gondor.apana.org.au>
 <20131107.170651.1819930710384730745.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, eric.dumazet@gmail.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:46123 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757069Ab3KHCSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 21:18:10 -0500
Content-Disposition: inline
In-Reply-To: <20131107.170651.1819930710384730745.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 05:06:51PM -0500, David Miller wrote:
> 
> Aside from the segmentation issues, Eric's patch was a nice cleanup
> which also made it such that we'd be able to get features back when
> the blocking condition gets removed.
> 
> Given all of this, would you like me to revert his change for now?

Oh no let's keep it as it is indeed a great cleanup and improvement
for LRO.  We can however remove the bits that relate to GRO.

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
