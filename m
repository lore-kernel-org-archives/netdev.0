From: David Miller <davem@davemloft.net>
Subject: Re: [patch 03/39] net: sched: Use hrtimer_resolution instead of
 hrtimer_get_res()
Date: Thu, 16 Apr 2015 12:04:14 -0400 (EDT)
Message-ID: <20150416.120414.15830203535976447.davem@davemloft.net>
References: <20150414203303.702062272@linutronix.de>
	<20150414203500.720623028@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org,
	mingo@kernel.org, preeti@linux.vnet.ibm.com,
	viresh.kumar@linaro.org, mtosatt@redhat.com, fweisbec@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33309 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752645AbbDPQER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:04:17 -0400
In-Reply-To: <20150414203500.720623028@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 14 Apr 2015 21:08:28 -0000

> No point in converting a timespec now that the value is directly
> accessible.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Acked-by: David S. Miller <davem@davemloft.net>
