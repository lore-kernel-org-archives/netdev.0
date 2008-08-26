From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 26 Aug 2008 17:35:08 +1000
Message-ID: <20080826073508.GA1039@gondor.apana.org.au>
References: <20080822.044248.175133807.davem@davemloft.net> <20080822120918.GB14981@ff.dom.local> <20080822121144.GA32397@gondor.apana.org.au> <20080822.051841.259820995.davem@davemloft.net> <20080822124556.GA15788@gondor.apana.org.au> <20080824192639.587f9391@speedy> <20080824234947.GA19018@gondor.apana.org.au> <20080824202922.2cc9b9f6@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55368 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752075AbYHZHfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 03:35:16 -0400
Content-Disposition: inline
In-Reply-To: <20080824202922.2cc9b9f6@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 24, 2008 at 08:29:22PM -0400, Stephen Hemminger wrote:
> 
> But then you couldn't replace tfifo with pfifo or tbf??

Couldn't the user install TBF as a parent of netem instead?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
