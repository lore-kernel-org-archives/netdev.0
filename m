From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: 8139cp: fix a BUG_ON triggered by wrong
 bytes_compl
Date: Fri, 29 Nov 2013 16:19:20 -0500 (EST)
Message-ID: <20131129.161920.119393762714075664.davem@davemloft.net>
References: <1385525270-56580-1-git-send-email-yangyingliang@huawei.com>
	<1385526903.5352.6.camel@edumazet-glaptop2.roam.corp.google.com>
	<52959214.7000501@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	dwmw2@infradead.org, dave.taht@bufferbloat.net
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab3K2VTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 16:19:22 -0500
In-Reply-To: <52959214.7000501@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Wed, 27 Nov 2013 14:32:52 +0800

> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> Using iperf to send packets(GSO mode is on), a bug is triggered:
 ...
> When a skb has frags, bytes_compl plus skb->len nr_frags times in cp_tx().
> It's not the correct value(actually, it should plus skb->len once) and it
> will trigger the BUG_ON(bytes_compl > num_queued - dql->num_completed).
> So only increase bytes_compl when finish sending all frags. pkts_compl also
> has a wrong value, fix it too.
> 
> It's introduced by commit 871f0d4c("8139cp: enable bql").
> 
> Suggested-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Applied and queued up for -stable, thanks.
