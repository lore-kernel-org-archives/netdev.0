From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 13 Jan 2005 00:19:02 +0100
Message-ID: <16869.45158.194375.398326@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501121621.24259.jeremy.guthrie@berbee.com>
	<16869.42247.126428.508479@robur.slu.se>
	<200501121647.30934.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501121647.30934.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > Here is what it looked like I was getting before from the old driver... that 
 > took me down to 8mbps.
 > 
 > "printk: 4624 messages suppressed.
 > dst cache overflow
 > printk: 4630 messages suppressed.
 > dst cache overflow
 > printk: 4631 messages suppressed.
 > dst cache overflow
 > printk: 4646 messages suppressed.
 > dst cache overflow
 > printk: 4645 messages suppressed.
 > dst cache overflow"
 
 Thanks! 

 This a known problem. Remember I asked you about this. We're now in the 
 RCU route-hash problem again. This is not necessary solved by more CPU
 as higher t-put forces more dst-entries to be freed aand we get 
 closer to max_size.

 As your traffic looks sane double your bucket size of the route hash to 
 start with. Use the boot option w. rhash_entries. look at rtstat  


						  --ro.
