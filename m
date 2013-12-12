From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched/sch_tbf.c: fix linking error
Date: Thu, 12 Dec 2013 12:25:42 -0500 (EST)
Message-ID: <20131212.122542.1538675820432940524.davem@davemloft.net>
References: <1386851936-1582-1-git-send-email-qais.yousef@imgtec.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yangyingliang@huawei.com, edumazet@google.com, jhs@mojatatu.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
To: qais.yousef@imgtec.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386851936-1582-1-git-send-email-qais.yousef@imgtec.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Qais Yousef <qais.yousef@imgtec.com>
Date: Thu, 12 Dec 2013 12:38:56 +0000

> ERROR: "__udivdi3" [net/sched/sch_tbf.ko] undefined!
> 
> introduced by: cc106e441a63 (net: sched: tbf: fix the calculation of max_size)
> 
> which adds a 64 by 32 bit division without using do_div().
> Fix it by using do_div(len/ 53) instead of len/53.
> 
> Signed-off-by: Qais Yousef <qais.yousef@imgtec.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-next@vger.kernel.org
> ---
> We caught this error on linux-next today. This is my quick attemp of a fix.
> If it's not appropriate or doesn't make sense my apologies and feel free to
> resend a better fix :)

This is already fixed in the net-next tree.
