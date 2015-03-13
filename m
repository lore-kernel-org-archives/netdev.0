From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Fri, 13 Mar 2015 18:06:27 +1100
Message-ID: <20150313070627.GA31116@gondor.apana.org.au>
References: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150311064241.GA7153@gondor.apana.org.au>
 <20150312165733.GB11089@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, daniel@iogearbox.net,
	David.Laight@aculab.com, davem@davemloft.net, pablo@netfilter.org,
	johunt@akamai.com, kaber@trash.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:60422 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbbCMHHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 03:07:12 -0400
Content-Disposition: inline
In-Reply-To: <20150312165733.GB11089@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2015 at 04:57:33PM +0000, Thomas Graf wrote:
>
> I agree that the max elements should be enforced by users as done by
> Netlink right now. I'm also fine with ditching nelems from rhashtable
> as long as shrinking is covered. Patrick mentioned several times by
> now that nft sets want to have shrinking.

My plan is to have expansions triggered solely through insert,
either immediate or delayed, and shrinking will only be done
when explicitly requested by the user.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
