From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v4 net-next] net: introduce dev_set_forwarding()
Date: Fri, 8 Nov 2013 11:22:08 +0800
Message-ID: <20131108032208.GA14056@gondor.apana.org.au>
References: <1383584130.1553.2.camel@bwh-desktop.uk.level5networks.com>
 <20131107.161755.355597965034457889.davem@davemloft.net>
 <20131107213111.GA6885@gondor.apana.org.au>
 <20131107.170651.1819930710384730745.davem@davemloft.net>
 <20131108021758.GA13467@gondor.apana.org.au>
 <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	christoph.paasch@uclouvain.be, netdev@vger.kernel.org,
	hkchu@google.com, mwdalton@google.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:45432 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753652Ab3KHDWP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 22:22:15 -0500
Content-Disposition: inline
In-Reply-To: <1383878554.9412.153.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 07, 2013 at 06:42:34PM -0800, Eric Dumazet wrote:
> On Fri, 2013-11-08 at 10:17 +0800, Herbert Xu wrote:
> 
> > Oh no let's keep it as it is indeed a great cleanup and improvement
> > for LRO.  We can however remove the bits that relate to GRO.
> 
> What about doing a benchmark first ?

If it really hurt then they can always turn it off using ethtool.
With your patch that automatically turns it off virt folks have
no way of even turning it on.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
