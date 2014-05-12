From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sch_hhf: fix comparison of qlen and limit
Date: Mon, 12 May 2014 14:55:33 -0400 (EDT)
Message-ID: <20140512.145533.1713460863760128476.davem@davemloft.net>
References: <1399625345-6588-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, vtlam@google.com,
	nanditad@google.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbaELSzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 14:55:35 -0400
In-Reply-To: <1399625345-6588-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Fri, 9 May 2014 16:49:05 +0800

> When I use the following command, eth0 cannot send any packets.
>  #tc qdisc add dev eth0 root handle 1: hhf limit 1
> 
> Because qlen need be smaller than limit, all packets were dropped.
> Fix this by qlen *<=* limit.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Applied, thanks.
