From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 22:34:51 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308061834.WAA01878@dub.inr.ac.ru>
References: <16177.18187.429888.128929@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se (Robert Olsson)
In-Reply-To: <16177.18187.429888.128929@robur.slu.se> from "Robert Olsson" at Aug 06, 2003 08:20:59 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>  No correct RCU patches are not applied but even before the RCU pathes we 
>  didn't see dst cache overflow during DoS if the routing table was fully 
>  loaded and we used hash chain limit patch. 

Sure. :-) Robert, did not we discover a week ago that the reason of rcu
stalls is rt_run_flush() which runs only when routes change? :-)

By the way, to refresh your memory, months ago there was another reason
for overflows. It was fixed by setting sane value to ip_rt_gc_min_interval.
RCU showed on surface after this.

Alexey
