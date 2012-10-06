From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] GRO scalability
Date: Sat, 6 Oct 2012 18:56:18 +0800
Message-ID: <20121006105618.GA28591@gondor.apana.org.au>
References: <1348769990.5093.1584.camel@edumazet-glaptop>
 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
 <1348841041.5093.2477.camel@edumazet-glaptop>
 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
 <1349448747.21172.113.camel@edumazet-glaptop>
 <20121006041155.GA27134@gondor.apana.org.au>
 <1349500126.4883.4.camel@edumazet-laptop>
 <20121006051407.GA27390@gondor.apana.org.au>
 <1349504541.21172.183.camel@edumazet-glaptop>
 <1349506825.21172.241.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sting.hengli.com.au ([178.18.18.71]:58320 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750749Ab2JFK4Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 06:56:25 -0400
Content-Disposition: inline
In-Reply-To: <1349506825.21172.241.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 06, 2012 at 09:00:25AM +0200, Eric Dumazet wrote:
> On Sat, 2012-10-06 at 08:22 +0200, Eric Dumazet wrote:
> 
> > All drivers.
> > 
> > If the napi->poll() consumes all budget, we dont call napi_complete()
> 
> Probably nobody noticed, because TCP stack retransmits packets
> eventually.
> 
> But this adds unexpected latencies.
> 
> I'll send a patch.

Yeah we should definitely do a flush in that case.  Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
