From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 23:01:13 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308061901.XAA01942@dub.inr.ac.ru>
References: <16177.19956.596928.527997@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se (Robert Olsson)
In-Reply-To: <16177.19956.596928.527997@robur.slu.se> from "Robert Olsson" at Aug 06, 2003 08:50:28 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>  if (in_hit < in_slow_tot) 
> 	ip_rt_gc_elasticity2 = 1;
>  else 
>          ip_rt_gc_elasticity2 = 2*ip_rt_gc_elasticity;
> 
>  would have been cleaner

It is _much_ cleaner.


> but maybe it's not worth it.

Well, it is wrong before all. With default settings for number of flows
at pktgen you will get always 1 not depending on length of flow at all.
No hits just because cache is too small. See? It is the problem.

Alexey
