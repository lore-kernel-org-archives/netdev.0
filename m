From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: net/ipv4/route.c GC patch: is this insane?b4Db3tL
Date: Mon, 31 May 2004 14:43:33 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16571.10357.391130.128260@robur.slu.se>
References: <20040530151434.GE24955@fooishbar.org>
	<16571.9006.703294.10134@robur.slu.se>
	<20040531122608.GR24955@fooishbar.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniel Stone <daniel@fooishbar.org>
In-Reply-To: <20040531122608.GR24955@fooishbar.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Daniel Stone writes:

 > gc_min_interval was zero - should this increase, or what?.

 If I remember correctly this was an artifact when used by /proc. Try to 
 set this value via source and avoid /proc for this. In 2.6 it's something 
 like:

 int ip_rt_gc_min_interval	= HZ / 2;

 Cheers.
						--ro
