From: David Miller <davem@davemloft.net>
Subject: Re: [patch 31/39] net: core: pktgen: Remove bogus hrtimer_active()
 check
Date: Thu, 16 Apr 2015 12:04:21 -0400 (EDT)
Message-ID: <20150416.120421.898004929174813546.davem@davemloft.net>
References: <20150414203303.702062272@linutronix.de>
	<20150414203503.165258315@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org,
	mingo@kernel.org, preeti@linux.vnet.ibm.com,
	viresh.kumar@linaro.org, mtosatt@redhat.com, fweisbec@gmail.com,
	netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33323 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753307AbbDPQEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 12:04:23 -0400
In-Reply-To: <20150414203503.165258315@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 14 Apr 2015 21:09:16 -0000

> The check for hrtimer_active() after starting the timer is
> pointless. If the timer is inactive it has expired already and
> therefor the task pointer is already NULL.
> 
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Acked-by: David S. Miller <davem@davemloft.net>
