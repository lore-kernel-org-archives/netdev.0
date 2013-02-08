From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] ipv6: fix a RCU warning in
 net/ipv6/ip6_flowlabel.c
Date: Fri, 08 Feb 2013 17:57:19 -0500 (EST)
Message-ID: <20130208.175719.570595882555864927.davem@davemloft.net>
References: <1360288360-20385-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38094 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757385Ab3BHW5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 17:57:21 -0500
In-Reply-To: <1360288360-20385-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Fri,  8 Feb 2013 09:52:40 +0800

> This patch fixes the following RCU warning:
> 
> [   51.680236] ===============================
> [   51.681914] [ INFO: suspicious RCU usage. ]
> [   51.683610] 3.8.0-rc6-next-20130206-sasha-00028-g83214f7-dirty #276 Tainted: G        W
> [   51.686703] -------------------------------
> [   51.688281] net/ipv6/ip6_flowlabel.c:671 suspicious rcu_dereference_check() usage!
> 
> we should use rcu_dereference_bh() when we hold rcu_read_lock_bh().
> 
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied.
