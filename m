From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] net: sched: do not requeue a NULL skb
Date: Thu, 14 Apr 2016 01:29:30 -0400 (EDT)
Message-ID: <20160414.012930.746981483324064373.davem@davemloft.net>
References: <1460443552-26710-1-git-send-email-larper@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	linux-kernel@vger.kernel.org, xiyou.wangcong@gmail.com,
	eric.dumazet@gmail.com, larper@axis.com
To: lars.persson@axis.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460443552-26710-1-git-send-email-larper@axis.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lars Persson <lars.persson@axis.com>
Date: Tue, 12 Apr 2016 08:45:52 +0200

> A failure in validate_xmit_skb_list() triggered an unconditional call
> to dev_requeue_skb with skb=NULL. This slowly grows the queue
> discipline's qlen count until all traffic through the queue stops.
> 
> We take the optimistic approach and continue running the queue after a
> failure since it is unknown if later packets also will fail in the
> validate path.
> 
> Fixes: 55a93b3ea780 ("qdisc: validate skb without holding lock")
> Signed-off-by: Lars Persson <larper@axis.com>

Applied and queued up for -stable, thanks.
