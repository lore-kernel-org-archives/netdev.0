From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] sch_tbf: add TBF_BURST/TBF_PBURST attribute
Date: Thu, 26 Dec 2013 13:54:56 -0500 (EST)
Message-ID: <20131226.135456.819247318672100181.davem@davemloft.net>
References: <52AFC64F.2070100@huawei.com>
	<1387484113.19078.375.camel@edumazet-glaptop2.roam.corp.google.com>
	<52B39C5F.1010101@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753672Ab3LZSy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Dec 2013 13:54:58 -0500
In-Reply-To: <52B39C5F.1010101@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Fri, 20 Dec 2013 09:24:47 +0800

> From: Yang Yingliang <yangyingliang@huawei.com>
> 
> When we set burst to 1514 with low rate in userspace,
> the kernel get a value of burst that less than 1514,
> which doesn't work.
> 
> Because it may make some loss when transform burst
> to buffer in userspace. This makes burst lose some
> bytes, when the kernel transform the buffer back to
> burst.
> 
> This patch adds two new attributes to support sending
> burst/mtu to kernel directly to avoid the loss.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Applied, thanks.
