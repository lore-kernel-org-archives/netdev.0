From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] fq_codel: explicitly reset flows in ->reset()
Date: Sun, 02 Aug 2015 17:20:28 -0700 (PDT)
Message-ID: <20150802.172028.327907117686065749.davem@davemloft.net>
References: <1438390419-30414-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, agartrell@fb.com, jhs@mojatatu.com,
	eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751875AbbHCAU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 20:20:29 -0400
In-Reply-To: <1438390419-30414-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 31 Jul 2015 17:53:39 -0700

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Alex reported the following crash when using fq_codel
> with htb:
 ...
> As Jamal pointed out, there is actually no need to call dequeue
> to purge the queued skb's in reset, data structures can be just
> reset explicitly. Therefore, we reset everything except config's
> and stats, so that we would have a fresh start after device flipping.
> 
> Fixes: 4b549a2ef4be ("fq_codel: Fair Queue Codel AQM")
> Reported-by: Alex Gartrell <agartrell@fb.com>
> Cc: Alex Gartrell <agartrell@fb.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> [xiyou.wangcong@gmail.com: added codel_vars_init() and qdisc_qstats_backlog_dec()]
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
