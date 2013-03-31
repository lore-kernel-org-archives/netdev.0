From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V4 2/4] PHYLIB: queue work on unbound wq
Date: Sun, 31 Mar 2013 12:45:22 -0400 (EDT)
Message-ID: <20130331.124522.495583446567617837.davem@davemloft.net>
References: <cover.1364740180.git.viresh.kumar@linaro.org>
	<cover.1364740180.git.viresh.kumar@linaro.org>
	<6be4e9ad2048a2a9d60143f58931c3fe94770175.1364740180.git.viresh.kumar@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org,
	robin.randhawa@arm.com, Steve.Bannister@arm.com,
	Liviu.Dudau@arm.com, charles.garcia-tobin@arm.com,
	arvind.chauhan@arm.com, airlied@redhat.com, axboe@kernel.dk,
	tglx@linutronix.de, peterz@infradead.org, mingo@redhat.com,
	rostedt@goodmis.org, linux-rt-users@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: viresh.kumar@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6be4e9ad2048a2a9d60143f58931c3fe94770175.1364740180.git.viresh.kumar@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Viresh Kumar <viresh.kumar@linaro.org>
Date: Sun, 31 Mar 2013 20:01:45 +0530

> Phylib uses workqueues for multiple purposes. There is no real dependency of
> scheduling these on the cpu which scheduled them.
> 
> On a idle system, it is observed that and idle cpu wakes up many times just to
> service this work. It would be better if we can schedule it on a cpu which the
> scheduler believes to be the most appropriate one.
> 
> This patch replaces system_wq with system_unbound_wq for PHYLIB.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>

Acked-by: David S. Miller <davem@davemloft.net>
