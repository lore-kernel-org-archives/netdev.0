From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 25 Aug 2008 09:49:47 +1000
Message-ID: <20080824234947.GA19018@gondor.apana.org.au>
References: <20080822.044248.175133807.davem@davemloft.net> <20080822120918.GB14981@ff.dom.local> <20080822121144.GA32397@gondor.apana.org.au> <20080822.051841.259820995.davem@davemloft.net> <20080822124556.GA15788@gondor.apana.org.au> <20080824192639.587f9391@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36984 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752975AbYHXXt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2008 19:49:58 -0400
Content-Disposition: inline
In-Reply-To: <20080824192639.587f9391@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 24, 2008 at 07:26:39PM -0400, Stephen Hemminger wrote:
>
> Tfifo is there only to add the jitter based reordering. Netem has other
> better kinds of reordering as well.
> 
> Netem has to be able to put TBF in as a child qdisc. This is how loss
> plus rate control is done.

What about making TBF a child of tfifo instead? Alternatively
we could merge tfifo into netem.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
