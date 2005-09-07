From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Wed, 7 Sep 2005 17:03:17 +0200
Message-ID: <17183.309.317160.103056@robur.slu.se>
References: <43014E27.1070104@cosmosbay.com>
	<20050823190852.GA20794@netnation.com>
	<17163.32645.202453.145416@robur.slu.se>
	<20050824000158.GA8137@netnation.com>
	<20050825181111.GB14336@netnation.com>
	<20050825200543.GA6612@yakov.inr.ac.ru>
	<20050825212211.GA23384@netnation.com>
	<20050826115520.GA12351@yakov.inr.ac.ru>
	<17167.29239.469711.847951@robur.slu.se>
	<20050906235700.GA31820@netnation.com>
	<20050907011959.GA25725@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Simon Kirby <sim@netnation.com>, Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050907011959.GA25725@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Alexey Kuznetsov writes:

 > Robert, have you seen this pehonomenon already? Did you mean that SMP works
 > or that it never works (but this patch is valid only for UP)? Did it
 > become worse after 2.6.9?

 It was quite some time since I saw dst cache overflow and we use 2.6 
 in infrastructure. Anyway I was able to "tune" route cache so I see
 in our lab system on a SMP box. I think UP and SMP behaves the same 
 but with UP we could disable the deferred delete as Simon tested.

 I don't know if anything happen in 2.6.9 I don't think so. But any
 improvement in drivers or FIB lookup may increase the burden so we get
 overflows.

 We had some code that checked the RCU latency. 
  
 Cheers.
					--ro
