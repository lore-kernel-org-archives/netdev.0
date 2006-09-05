From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC]: searching  SAD without assumming L3 details
Date: Wed, 6 Sep 2006 09:38:23 +1000
Message-ID: <20060905233823.GA9217@gondor.apana.org.au>
References: <1157204582.5197.4.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:16657 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932209AbWIEXim
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Sep 2006 19:38:42 -0400
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1157204582.5197.4.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Sep 02, 2006 at 09:43:02AM -0400, jamal wrote:
>
> Allow for searching the SAD from external data path points without
> assumming L3 details. The only customer of this exposure currently
> is pktgen.

Any reason why xfrm_state_find can't be used? It doesn't look right
to add generic code that's only used by pktgen.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
