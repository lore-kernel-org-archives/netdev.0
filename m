From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bugme-new] [Bug 6666] New: invalid tcp socket connection to windows stacks
Date: Fri, 09 Jun 2006 14:48:07 +1000
Message-ID: <E1FoYul-0001hh-00@gondolin.me.apana.org.au>
References: <20060608103627.23cfc83a.akpm@osdl.org>
Cc: netdev@vger.kernel.org, technik@power-netz.de,
	bugme-daemon@bugzilla.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:40206 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S965156AbWFIEsU
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 00:48:20 -0400
To: akpm@osdl.org (Andrew Morton)
In-Reply-To: <20060608103627.23cfc83a.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
> 
> If it's buggy you get :
> 
> 11:24:15.021572 d59.x-mailer.de.59959 >
> cust.static.212-90-215-40.cybernet.ch.smtp: S 2028538653:2028538653(0) win 5840
> <mss 1460,sackOK,timestamp 243108498 0,nop,wscale 7> (DF)
> 11:24:15.076329 cust.static.212-90-215-40.cybernet.ch.smtp >
> d59.x-mailer.de.59959: S 2328498080:2328498080(0) ack 2028538654 win 16384 <mss
> 1400,nop,wscale 0,nop,nop,timestamp 0
> 0,nop,nop,sackOK>
> 11:24:15.076352 d59.x-mailer.de.59959 >
> cust.static.212-90-215-40.cybernet.ch.smtp: . ack 1 win 46 <nop,nop,timestamp
> 243108503 0> (DF)

...
 
> ### you should get kind of this:
> 
> 13:56:37.203297 d59.x-mailer.de.43286 >
> cust.static.212-90-215-40.cybernet.ch.smtp: S 1489507409:1489507409(0) win 5840
> <mss 1460,sackOK,timestamp 16627469 0,nop,wscale 2> (DF)
> 13:56:37.250827 cust.static.212-90-215-40.cybernet.ch.smtp >
> d59.x-mailer.de.43286: S 783498912:783498912(0) ack 1489507410 win 16384 <mss
> 1400,nop,wscale 0,nop,nop,timestamp 0 0,nop,nop,sackOK>
> 13:56:37.250888 d59.x-mailer.de.43286 >
> cust.static.212-90-215-40.cybernet.ch.smtp: . ack 1 win 1460 <nop,nop,timestamp
> 16627473 0> (DF)

Looks like the problem is window scaling.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
