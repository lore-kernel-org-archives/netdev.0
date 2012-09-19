From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sched: fix virtual-start-time update in QFQ
Date: Wed, 19 Sep 2012 16:25:06 -0400 (EDT)
Message-ID: <20120919.162506.1493337375457097539.davem@davemloft.net>
References: <20120915104134.GA29862@paolo-ThinkPad-W520>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, jhs@mojatatu.com, fchecconi@gmail.com,
	rizzo@iet.unipi.it, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: paolo.valente@unimore.it
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120915104134.GA29862@paolo-ThinkPad-W520>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paolo Valente <paolo.valente@unimore.it>
Date: Sat, 15 Sep 2012 12:41:35 +0200

> If the old timestamps of a class, say cl, are stale when the class
> becomes active, then QFQ may assign to cl a much higher start time
> than the maximum value allowed. This may happen when QFQ assigns to
> the start time of cl the finish time of a group whose classes are
> characterized by a higher value of the ratio
> max_class_pkt/weight_of_the_class with respect to that of
> cl. Inserting a class with a too high start time into the bucket list
> corrupts the data structure and may eventually lead to crashes.
> This patch limits the maximum start time assigned to a class.
> 
> Signed-off-by: Paolo Valente <paolo.valente@unimore.it>

Applied and queued up for -stable, thanks.

Please use "pkt_sched" instead of just plain "sched" in the prefixes
of your subject lines for packet scheduler changes so such changes
can be distinguished from process scheduler changes.

I fixed it up for you this time.

Thanks.
