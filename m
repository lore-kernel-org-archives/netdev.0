From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: add messages to distinguish errors
 when modify qdisc
Date: Tue, 10 Dec 2013 13:47:02 -0500 (EST)
Message-ID: <20131210.134702.693746793840315797.davem@davemloft.net>
References: <1386665340-16820-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yangyingliang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51132 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743Ab3LJSrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 13:47:06 -0500
In-Reply-To: <1386665340-16820-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yang Yingliang <yangyingliang@huawei.com>
Date: Tue, 10 Dec 2013 16:49:00 +0800

> When tc_modify_qdisc return EINVAL, user cannot distinguish
> errors easliy. Add some messages to make it easier.
> 
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

There is no chance I am ever going to apply a patch like this one,
sorry.

If the indication to userspace is not fine grained enough, fix that.
Don't spam the kernel log with random messages triggerable by the
user.
