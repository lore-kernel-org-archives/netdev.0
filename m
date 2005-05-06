From: Rick Jones <rick.jones2@hp.com>
Subject: Re: e1000 (?) jumbo frames performance issue
Date: Fri, 06 May 2005 09:18:59 -0700
Message-ID: <427B98F3.1020003@hp.com>
References: <200505051928.32496.m.iatrou@freemail.gr> <427A7F5B.8050704@hp.com> <200505060055.55778.m.iatrou@freemail.gr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Iatrou <m.iatrou@freemail.gr>
In-Reply-To: <200505060055.55778.m.iatrou@freemail.gr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> 
>>It might be good to add CPU utilization figures - for 2.3pl1 that means
>>editing the makefile to add a -DUSE_PROC_STAT and recompiling.  Or you can
>>grab netperf 2.4.0-rc3 from:
>>
>>ftp://ftp.cup.hp.com/dist/networking/benchmarks/netperf/experimental/
>>
>>if you cannot find it elsewhere, and that will (try to) compile-in the
>>right CPU utilization mechanism automagically.
> 
> 
> I already did a custom CPU usage instrumentation (based on infos 
> from /proc/stat -- the latest netperf does the same thing, doesn't it?) and 
> it seems that system has plenty of idle time (up to 50% if I recall correct)

IIRC you stated that the boxes were UP?

If changing netperf settings didn't affect much, then kernel profiles and/or 
packet traces may be in order.

rick
