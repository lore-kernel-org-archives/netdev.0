From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [Fwd: [E1000] NAPI re-insertion w/ changes]
Date: Fri, 28 Mar 2003 19:43:22 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16004.38858.803274.216457@robur.slu.se>
References: <16003.11449.497905.815776@robur.slu.se>
	<slrnb86c3g.7vo.lunz@stoli.localnet>
	<16004.1914.582979.278009@robur.slu.se>
	<slrnb891ov.mf8.lunz@stoli.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
In-Reply-To: <slrnb891ov.mf8.lunz@stoli.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jason Lunz writes:
 > Robert.Olsson@data.slu.se said:
 > >  Can you test the patch I sent for 5.0.43 with your equipment/setup?
 > 
 > We have a winner! I called the driver with your patch 5.0.43-k1-ro1. I
 > also removed all the cyclesoak lines; all they really show is that
 > throughput is really sensitive to how much CPU time ksoftirqd gets.
 > 
 > http://gtf.org/lunz/linux/net/perf/ is still the url.

 Excellent!

 We have a flat performance curve at ~350 kpps at any load and packet size 
 again. Of course this can be improved further.

 I think Intel still did the hard work but left the "fine" tuning and testing 
 for us. :-) 

 I guess we propose the patch to maintainers.

 Cheers
						--ro
 
