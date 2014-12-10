From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix suspicious rcu_dereference_check in
 net/sched/sch_fq_codel.c
Date: Tue, 09 Dec 2014 21:49:37 -0500 (EST)
Message-ID: <20141209.214937.30977416178126165.davem@davemloft.net>
References: <58905.1418159750@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, john.r.fastabend@intel.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58905.1418159750@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
Date: Tue, 09 Dec 2014 16:15:50 -0500

> commit 46e5da40ae (net: qdisc: use rcu prefix and silence
>  sparse warnings) triggers a spurious warning:
> 
> net/sched/sch_fq_codel.c:97 suspicious rcu_dereference_check() usage!
> 
> The code should be using the _bh variant of rcu_dereference.
> 
> Signed-off-by: Valdis Kletnieks <valdis.kletnieks@vt.edu>

Applied and queued up for -stable, thanks.
