From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: inter-packet gap in pktgen
Date: Wed, 8 Dec 2004 11:21:54 +0100
Message-ID: <16822.54722.755218.745451@robur.slu.se>
References: <20041207222522.GA30266@xi.wantstofly.org>
	<41B632F3.1090104@candelatech.com>
	<20041208073858.GA4027@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Ben Greear <greearb@candelatech.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>, hadi@cyberus.ca,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20041208073858.GA4027@xi.wantstofly.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Lennert Buytenhek writes:
 > 
 > Another option is:
 > 
 > 	next_tx = get_time_in_ns();
 > 	while (--count) {
 > 		tx_packet();
 > 		next_tx += 1e9/intended_pps;
 > 		nanospin(next_tx - get_time_in_ns());
 > 	}

 Hello!

 I think this what Ben is doing with his userland app. Ev. adjusting
 the ipg delay in runtime? A kind of control system. Even the device 
 stats could possible be read.

 
 > This should be relatively independent of system load.  OK, I know,
 > time to show some code.
 
 Also an idea might be to have some kind of option to use pktgen w. 
 existent qdisc/tc infrastructure for this type of tests. Ben did
 you try this?
 
						--ro
