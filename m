From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Fri, 14 Jan 2005 16:44:15 +0100
Message-ID: <16871.59599.43835.954744@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501131328.34449.jeremy.guthrie@berbee.com>
	<16870.58414.767012.96364@robur.slu.se>
	<200501131627.20360.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501131627.20360.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > 
 > IN:Hits are cache hits yes?  Tot, are the total number of flows created since 
 > we last looked at the total flow count, correct?  

 Thats correct.

 > What would cause a packet to drop in the network stack and thus showup in 
 > /proc/net/softnet_stat?
 
 Only netif_rx (non-NAPI) driver drops in the backlog. NAPI drivers drops early 
 in device.

 > Performance has picked up.  I am not dropping packets anymore except during 
 > GC.  I upped my interval from 600 seconds to 1800 seconds.   

 Yes and as far as I see you have CPU left the as RX interrupts on eth3 indicates
 (if the patch is applied) but also the low numbers of time squeeze in sofnet_stat

						   --ro
