From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Wed, 7 Sep 2005 18:49:03 +0200
Message-ID: <17183.6655.977975.249491@robur.slu.se>
References: <20050823190852.GA20794@netnation.com>
	<17163.32645.202453.145416@robur.slu.se>
	<20050824000158.GA8137@netnation.com>
	<20050825181111.GB14336@netnation.com>
	<20050825200543.GA6612@yakov.inr.ac.ru>
	<20050825212211.GA23384@netnation.com>
	<20050826115520.GA12351@yakov.inr.ac.ru>
	<17167.29239.469711.847951@robur.slu.se>
	<20050906235700.GA31820@netnation.com>
	<17182.64751.340488.996748@robur.slu.se>
	<20050907162854.GB24735@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050907162854.GB24735@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Simon Kirby writes:

 > Yes, setting maxbatch to 10000 also results in working gc, though routing
 > throughput is about 5.7% higher when just calling dst_free directly.

 Oh that's good news... You loose 5.7% for rDoS but should benefit 
 in normal conditions.

 > There was discussion about this before (recycling of existing entries is
 > also now impossible, as compared with 2.4).  It's a shame that this win
 > for the normal case also hurts the DoS case...and it really hurts when
 > the when the DoS case is the normal case.

 It's called trade-off's :) rDoS is hardly nomal case? But maybe it's time 
 to compare routing via route hash vs FIB lookup directly again now when 
 we have RCU with some FIB lookup's too.


 Cheers.
						--ro
