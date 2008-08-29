From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: cpu utilisation improvement when not doing netif_tx_{stop,wake}_queue()
Date: Fri, 29 Aug 2008 17:15:20 +1000
Message-ID: <E1KYyCW-00025D-00@gondolin.me.apana.org.au>
References: <20080828164638.GA25919@xi.wantstofly.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org, dale@farnsworth.org,
	nico@cam.org
To: buytenh@wantstofly.org (Lennert Buytenhek)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44476 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751091AbYH2HP2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2008 03:15:28 -0400
In-Reply-To: <20080828164638.GA25919@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek <buytenh@wantstofly.org> wrote:
> 
> I.e. transmitting wire speed gigabit over a single TCP session takes
> around 90% CPU time (measured with cyclesoak) if I have the TX queue
> flow control enabled, but only 70% if I rip the TX queue flow control
> out.  (This is on a relatively underpowered ARM box.)

How many cores and how many queues?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
