From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] repairing rtcache killer
Date: Wed, 6 Aug 2003 21:14:56 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200308061714.VAA01614@dub.inr.ac.ru>
References: <16175.58503.134543.310459@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, Robert.Olsson@data.slu.se, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert.Olsson@data.slu.se (Robert Olsson)
In-Reply-To: <16175.58503.134543.310459@robur.slu.se> from "Robert Olsson" at Aug 05, 2003 07:08:23 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

>  For autotuning I think we can have help from a ratio of warm cache hits (in_hit)
>  and misses (in_slow_tot) to set threshhold to trim hash chain lengths.

Have you already forgotten the whole day lost staring to some impossible
numbers for number of misses? :-)

The only output which you can get from ratio hits/misses is to _increase_
size of cache when number of misses growth. It is not only useless, it
is exactly opposite to the behaviour which you want to see.

We want to shrink it at DoS, remember? I still do not know any criterium,
apparently it should be based not on ratio hits/misses, but on absolute
rates or something like that. average/max = 1/2 is always acceptable,
perfect at normal flow rates and not disasterous even for 1packet/flow.

Alexey
