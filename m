From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend net-next] sch_tbf: add TBF_BURST/TBF_PBURST
 attribute
Date: Thu, 19 Dec 2013 15:03:14 -0500 (EST)
Message-ID: <20131219.150314.2040749867653163114.davem@davemloft.net>
References: <1386927716-7896-1-git-send-email-yangyingliang@huawei.com>
	<52AFC64F.2070100@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35608 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756038Ab3LSUDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 15:03:16 -0500
In-Reply-To: <52AFC64F.2070100@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Tue, 17 Dec 2013 11:34:39 +0800

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

I really want to see some review of this change, thanks.
