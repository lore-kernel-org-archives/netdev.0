From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: net/ipv4/route.c GC patch: is this insane?
Date: Mon, 31 May 2004 17:06:00 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16571.18904.498197.739753@robur.slu.se>
References: <20040530151434.GE24955@fooishbar.org>
	<16571.9006.703294.10134@robur.slu.se>
	<20040531122608.GR24955@fooishbar.org>
	<16571.10357.391130.128260@robur.slu.se>
	<20040531140801.GS24955@fooishbar.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Stone <daniel@fooishbar.org>
In-Reply-To: <20040531140801.GS24955@fooishbar.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Daniel Stone writes:

 > >  int ip_rt_gc_min_interval	= HZ / 2;
 > 
 > This appears to already be the case, in 2.4.23's net/ipv4/route.c, at
 > any rate.

 OK! 

 Well take a look at route stats /proc/net/rt_cache_stat (you can use 
 rtstat app with a vmstat-like output) to ensure things are normal.
 If so you can try to decrease ip_rt_gc_min_interval further. 
 
 Cheers.
						--ro
