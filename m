From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Thu, 20 Jan 2005 12:30:01 +0100
Message-ID: <16879.38457.4576.598144@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501190903.45671.jeremy.guthrie@berbee.com>
	<16878.56487.600435.442912@robur.slu.se>
	<200501191950.08567.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501191950.08567.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > @ 14:51:44 we can see the secret_interval kick in.  Otherwise we run very 
 > solid.  
 > 
 > 101Kpps  8)

 Seems traffic increaed a little bit too?

 > 1024 buffers on the RX of eth3.
 > 
 > echo 86400 > /proc/sys/net/ipv4/route/secret_interval
 > echo 524288 > /proc/sys/net/ipv4/route/gc_thresh

 rhash_entries?

 > It appears to be cruising right along now.

 Nice. rtstat's is still interesting so we can see number fib lookups and
 linear search and GC dynamics etc.


						--ro

 
