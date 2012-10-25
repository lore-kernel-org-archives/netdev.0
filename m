From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: get rid of the useless function of
 nlmsg_get_pos()
Date: Thu, 25 Oct 2012 15:44:53 -0400 (EDT)
Message-ID: <20121025.154453.851955498748796353.davem@davemloft.net>
References: <1351159208-9308-1-git-send-email-zhanghonghui@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, lizefan@huawei.com,
	netdev@vger.kernel.org
To: zhanghonghui@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39560 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760106Ab2JYToz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 15:44:55 -0400
In-Reply-To: <1351159208-9308-1-git-send-email-zhanghonghui@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <zhanghonghui@huawei.com>
Date: Thu, 25 Oct 2012 18:00:08 +0800

> From: Hans Zhang <zhanghonghui@huawei.com>
> 
> This function just report the pointer of skb->tail, and there's only
> one use in the kernel.
> 
> Signed-off-by: Hans Zhang <zhanghonghui@huawei.com>

I'm not applying this.

It is obviously useful to somebody, otherwise you wouldn't need
to do anything other than remove the implementation.

It provides an implicit cast, and in that sense it's useful.
