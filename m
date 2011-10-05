From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Wed, 05 Oct 2011 02:58:17 -0400
Message-ID: <6.2.5.6.2.20111005025227.03a9d9f0@binnacle.cx>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Joe Perches <joe@perches.com>, Christoph Lameter <cl@gentwo.org>,
	Serge Belyshev <belyshev@depni.sinp.msu.ru>,
	Con Kolivas <kernel@kolivas.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Final note:

I had captured latency measurements for
two of the three kernels.  Just ran
2.6.18(rhel5) and the results are
stunning.  The older kernel is much,
much better then the newer kernel.

Average latency is three times better
and the standard deviation is six
time better.  As in 300% and 600%.

Latency here is the time it takes
a packet to travel from the kernel
(where it is timestamped) till it
reaches the final consumption point
in the application.

Makes me think that the old kernel
is better at keeping caches hot and
scheduling woken threads on the same
cores as the threads that triggered
them.
