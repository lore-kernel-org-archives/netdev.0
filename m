From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: fix a regression in tc actions
Date: Fri, 20 Dec 2013 17:07:10 -0500 (EST)
Message-ID: <20131220.170710.102842674471432958.davem@davemloft.net>
References: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751904Ab3LTWHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 17:07:11 -0500
In-Reply-To: <1387526931-21814-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 20 Dec 2013 00:08:51 -0800

> This patch fixes:
> 1) pass mask rather than size to tcf_hashinfo_init()
> 2) the cleanup should be in reversed order in mirred_cleanup_module()
> 
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Fixes: 369ba56787d7469c0afd ("net_sched: init struct tcf_hashinfo at register time")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
