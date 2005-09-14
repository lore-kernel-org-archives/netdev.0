From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: Route cache performance
Date: Wed, 14 Sep 2005 10:04:21 +0200
Message-ID: <17191.55685.861191.831981@robur.slu.se>
References: <20050824000158.GA8137@netnation.com>
	<20050825181111.GB14336@netnation.com>
	<20050825200543.GA6612@yakov.inr.ac.ru>
	<20050825212211.GA23384@netnation.com>
	<20050826115520.GA12351@yakov.inr.ac.ru>
	<17167.29239.469711.847951@robur.slu.se>
	<20050906235700.GA31820@netnation.com>
	<17182.64751.340488.996748@robur.slu.se>
	<20050907162854.GB24735@netnation.com>
	<20050907195911.GA8382@yakov.inr.ac.ru>
	<20050913221448.GD15704@netnation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Eric Dumazet <dada1@cosmosbay.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Simon Kirby <sim@netnation.com>
In-Reply-To: <20050913221448.GD15704@netnation.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Simon Kirby writes:


 > Sender: 367 Mbps, 717883 pps valid src/dst, 64 byte (Ethernet) packets
 > 
 > 2.4.27-rc1: 297 Mbps forwarded (w/idle time?!)
 > 2.4.31: 296 Mbps forwarded (w/idle time?!)
 > 2.6.13-rc6: 173 Mbps forwarded

 > Time permitting, I'd also like to run some profiles.  It's interesting
 > to note that 2.6 is slower at forwarding even straight duplicate small
 > packets.  We should definitely get to the bottom of that.

 Yes. This is single flow? Strange.

 Run a fixed size shot 10Mpkts pkts or so for both 2.4 and 2.6 and save 
 /proc/interrupts, proc/net/softnetstat, netstat -i, tc -s qdisc to start with.
 
 A profile on 2.6 could solve the confusion.

 Cheers.
						--ro

 
