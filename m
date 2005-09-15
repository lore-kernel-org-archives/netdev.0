From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Thu, 15 Sep 2005 23:30:54 +0200
Message-ID: <17193.59406.200787.819069@robur.slu.se>
References: <20050825181111.GB14336@netnation.com>
	<20050825200543.GA6612@yakov.inr.ac.ru>
	<20050825212211.GA23384@netnation.com>
	<20050826115520.GA12351@yakov.inr.ac.ru>
	<17167.29239.469711.847951@robur.slu.se>
	<20050906235700.GA31820@netnation.com>
	<17182.64751.340488.996748@robur.slu.se>
	<20050907162854.GB24735@netnation.com>
	<20050907195911.GA8382@yakov.inr.ac.ru>
	<20050913221448.GD15704@netnation.com>
	<20050915210432.GD28925@yakov.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Simon Kirby <sim@netnation.com>, Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
In-Reply-To: <20050915210432.GD28925@yakov.inr.ac.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Alexey Kuznetsov writes:

 > Most likely it is driver or something is seriously screwed up in softirq
 > processing. Profiling is really required...
 > 
 > Robert, did you not see anything like this?

 No. There must be an explanation... I've seen around 1 Mpps in the best
 single flow tests w. 2.6 kernels of course decent HW. Simon can you 
 report in pps as you use 64 byte pkts.

 > Before 2.6.9 rcu worked differently. It run very rarely and had to do
 > lots of work each run, effectively unlimited. Apparently, when RCU folks
 > finally implemented new better mechanism they also added some job limit
 > and did this wrong, 10 is ridiculously low limit.

 Yes. I'll guess the thinking was that RCU is for read mostly and rDoS 
 violates this but yes 10 seems dangerous low.

 Also interesing to get BSD numbers? Sounds like they use something like
 old FASTROUTE.

 Cheers.
					--ro
