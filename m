From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 20:50:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16177.19956.596928.527997@robur.slu.se>
References: <16177.14760.612648.582063@robur.slu.se>
	<200308061806.WAA01763@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se (Robert Olsson), davem@redhat.com,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200308061806.WAA01763@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


kuznet@ms2.inr.ac.ru writes:

 > It is the system with positive feedback. Reduction of chain length
 > results in increasing amount of misses and so on. Under normal load
 > it has the only stable state, zero chain length and will never leave it.
 > 
 > hits/misses is wrong feedback, unless you use it to increase chain length. :-)
 > 

 Well is was not the intention to find any optimum or equilibrium point
 the idea was just to get a different and more agressive setting pure DoS 
 attacks to start with. 

 Something like:

 if (in_hit < in_slow_tot) 
	ip_rt_gc_elasticity2 = 1;
 else 
         ip_rt_gc_elasticity2 = 2*ip_rt_gc_elasticity;

 would have been cleaner but maybe it's not worth it.


 Cheers.

						--ro
