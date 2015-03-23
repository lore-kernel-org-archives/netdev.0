From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v2 PATCH 7/10] rhashtable: Disable automatic shrinking
Date: Mon, 23 Mar 2015 20:28:07 +1100
Message-ID: <20150323092806.GA12506@gondor.apana.org.au>
References: <20150322080330.GA3416@gondor.apana.org.au>
 <E1YZard-0000wE-Se@gondolin.me.apana.org.au>
 <20150322121755.GH1185@casper.infradead.org>
 <20150323000954.GB9507@gondor.apana.org.au>
 <20150323083319.GB16023@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	Josh Triplett <josh@joshtriplett.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40349 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091AbbCWJ2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 05:28:35 -0400
Content-Disposition: inline
In-Reply-To: <20150323083319.GB16023@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 08:33:19AM +0000, Thomas Graf wrote:
>
> I'm not claiming you always want shrinking but what gain is there by
> removing integrated support? Can you show numbers that the additional
> branch actually hurts?

You never want automatic shrinking unless all your users are
trusted.  I doubt there would be many rhashtable users where
this would apply.  Even nft_hash is quite tenuous.

Besdies, if you really want automatic shrinking, you could always
do it in the caller of rhashtable_remove.  That way only you
would pay for the cost and not everybody else.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
