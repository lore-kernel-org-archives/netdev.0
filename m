From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: "dst cache overflow"
Date: Mon, 20 Sep 2004 21:44:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16719.13095.369830.547715@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert.Olsson@data.slu.se
Return-path: <netdev-bounce@oss.sgi.com>
To: cd@cdaniel.de
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hello!

 size   IN: hit     tot    mc no_rt bcast madst masrc  OUT: hit     tot     mc 
GC:tot ignore gmiss dstof HLS:in    out
10501       593     339     0     0     0     0     0       250      24      0
   362    360     2     0    229     48


The number of packets that hits the route hash is about the same as the
number of packets that misses it. (hit/tot)

Either your route hash is so small in that case increase rhash_entries. 
Or you are receiving a DoS attack.

I've sent a new version rtstat to Stepfen Hemminger.
ftp://robur.slu.se/pub/Linux/net-development/rt_cache_stat/rtstat.c


						--ro
