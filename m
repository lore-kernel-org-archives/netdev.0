From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 5 Jan 2005 21:22:55 +0100
Message-ID: <16860.19615.251360.169722@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<16860.5674.612383.986202@robur.slu.se>
	<200501051135.03493.jeremy.guthrie@berbee.com>
	<200501051325.40616.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501051325.40616.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > After smp_affinity adjustments and turning off IRQ balancing.
 > 
 > eth3      Link encap:Ethernet  HWaddr 00:02:B3:D5:7E:30

 >           RX packets:537271635 errors:2377048 dropped:2377048 overruns:1849169 

 Worse?

 Yes. I'll remember Hararld moved rt_cache_stat /proc/net/stats/ and wrote a 
 new utility for it. Should be in iproute2 package.  Stephen knows the
 details. Otherwise change path in rtstat. You need this to relate and 
 verify the load.

 Check throughtput and how packet load is used with 2.4. /proc/net/softnet_stat
 and rtstat. Also meditate how the comparison can be fair wrt taffic patterns.
 Do smame with 2.6.

 Prepare for a oprofile. I'm lazy and compile the stuff I use into kernel if 
 you can get the same result w. nodules it's ok.


						  --ro

 
