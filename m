From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH 2.6] generic network statistics (was Re: [6/6]: jenkins
	hash for neigh / Statistics)
Date: Tue, 28 Sep 2004 16:22:58 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16729.29634.992171.862677@robur.slu.se>
References: <20040925005623.2faf8faf.davem@davemloft.net>
	<E1CBu70-00010X-00@gondolin.me.apana.org.au>
	<20040927121403.767e2308.davem@davemloft.net>
	<20040927222613.GE3236@sunbeam.de.gnumonks.org>
	<20040927160636.7741d973.davem@davemloft.net>
	<1096327658.1729.19.camel@localhost.localdomain>
	<16729.9326.93269.422940@robur.slu.se>
	<20040928111906.GB29961@sunbeam.de.gnumonks.org>
	<1096375700.8659.235.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Harald Welte <laforge@gnumonks.org>,
        Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        "David S. Miller" <davem@davemloft.net>, herbert@gondor.apana.org.au,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1096375700.8659.235.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


jamal writes:
 > 
 > Thanks for changing the subject Harald (I wanted to catchup with that
 > thread at some point). 
 > Speaking of generic stats; i have a patch netlink ready which may need
 > some extensions. I did post it  a while back on netdev but didnt get
 > feedback.

 OK it's EWMA calc in kernel. For another purpose I tried another approach 
 to satisfy some users that wanted Cisco like average stats on our routers. 
 User app/daemon reads stats via netlink and does average calc. looks like:
 
 ifstat2  eth*
             RX --------------------------   TX -------------------------
eth0          389.4 M bit/s       40 k pps     20.7 M bit/s       40 k pps 
eth1            3.1 k bit/s        4   pps    686.5 k bit/s       65   pps 
eth2           19.3 M bit/s       37 k pps    363.5 M bit/s       38 k pps 


As usual most code is honestly stolen from Alexey. :-)

ftp://robur.slu.se/pub/Linux/net-development/ifstat2/

Cheers.
						--ro
