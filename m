From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: abysmal e1000 performance (DITR)
Date: Mon, 7 Jun 2004 21:14:27 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16580.48787.965298.891413@robur.slu.se>
References: <1085700138.30156.1322.camel@tubarao>
	<16580.33370.535347.85788@robur.slu.se>
	<1086631191.5220.15.camel@tubarao>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tharbaugh@lnxi.com
In-Reply-To: <1086631191.5220.15.camel@tubarao>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Thayne Harbaugh writes:
 > 
 > >  The only useful measure we found was using the number of packets
 > > received on the RX-ring. You see this used in tulip driver to get a
 > > dynamic RX interrupt delay. 
 > 
 > That, however, is exactly the problem.  When only the packets are
 > considered then interrupts are throttled even when the system can handle
 > the extra load of heavy interrupts.  When the interrupts are
 > unnecessarily throttled without considering the system load then network
 > throughput is greatly reduced - even though the system is mostly idle. 
 > That approach is too naive for balanced performance between network
 > throughput and application processing.
 > 
 > In the end, I thing that DITR should be disabled in favor of NAPI which
 > has a similar goal and is more general.

 I'm not arguing with you. NAPI uses just number of received packets to
 decide which action to take and the decision gets instant and simple.

 > FWIW, I haven't looked through the tulip driver.  Thanks for the pointer
 > - I'll go have a peek.

 Well it has a simple variant to avoid fixed interrupt delays and is used
 with NAPI in tulip. Jamal gave talk on this at OLS 2000?. 
 
 Cheers.
						--ro
