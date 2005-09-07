From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Wed, 7 Sep 2005 19:21:14 +0200
Message-ID: <17183.8586.47462.585303@robur.slu.se>
References: <17163.32645.202453.145416@robur.slu.se>
	<20050824000158.GA8137@netnation.com>
	<20050825181111.GB14336@netnation.com>
	<20050825200543.GA6612@yakov.inr.ac.ru>
	<20050825212211.GA23384@netnation.com>
	<20050826115520.GA12351@yakov.inr.ac.ru>
	<17167.29239.469711.847951@robur.slu.se>
	<20050906235700.GA31820@netnation.com>
	<20050907011959.GA25725@yakov.inr.ac.ru>
	<17183.309.317160.103056@robur.slu.se>
	<20050907165528.GC24735@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050907165528.GC24735@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Simon Kirby writes:

 > I've only been able to send 179 Mbps from one box, so that's what has
 > been killing it.  On the receiving end, 2.6.13-rc6 with the direct
 > dst_free now drops a bunch but stays responsive with working GC,
 > routing through about 69.6 Mbps, while 2.4.27 routes 103 Mbps worth.

 If route hash setup is identical, buckets etc and HZ is same etc. I have no 
 idea about the performance difference. Somebody else?  In other case you need 
 to compare (o)profiles and see if this can give us any hints. To test drivers 
 etc you might also want to test with a single flow.

 Cheers.
						--ro
