From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][IPSEC]: tunnel mode processing
Date: Fri, 01 Sep 2006 09:12:25 -0400
Message-ID: <1157116345.5057.92.camel@jzny2>
References: <1157072127.5057.39.camel@jzny2>
	 <20060901040713.GA9840@gondor.apana.org.au>
	 <1157113034.5057.62.camel@jzny2>
	 <20060901122255.GA18143@gondor.apana.org.au>
	 <1157115379.5057.84.camel@jzny2>
	 <20060901130438.GA18536@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:55962 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1750940AbWIANMa
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 09:12:30 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1GJ8ov-0006oo-Vs
	for netdev@vger.kernel.org; Fri, 01 Sep 2006 09:12:29 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20060901130438.GA18536@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-01-09 at 23:04 +1000, Herbert Xu wrote:

> Yes, I suppose you could even replace x->mode directly.
>
> > I am probably better off going back to creating a dummy dst with just
> > those two fields when in  tunnel mode;->
> 
> Probably.  Although if you write your own output function you could
> make it go faster by adapting it to the specifics of pktgen.

gah. Ok, probably better solution to go this path then ;->

cheers,
jamal

