From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix "queues" uevent between network namespaces
Date: Sun, 19 Jan 2014 20:04:42 -0800 (PST)
Message-ID: <20140119.200442.627716770426396484.davem@davemloft.net>
References: <1389864271-24212-1-git-send-email-chenweilong@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: chenweilong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990AbaATEEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 23:04:42 -0500
In-Reply-To: <1389864271-24212-1-git-send-email-chenweilong@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Weilong <chenweilong@huawei.com>
Date: Thu, 16 Jan 2014 17:24:31 +0800

> From: Weilong Chen <chenweilong@huawei.com>
> 
> When I create a new namespace with 'ip netns add net0', or add/remove
> new links in a namespace with 'ip link add/delete type veth', rx/tx
> queues events can be got in all namespaces. That is because rx/tx queue
> ktypes do not have namespace support, and their kobj parents are setted to
> NULL. This patch is to fix it.
> 
> Reported-by: Libo Chen <chenlibo@huawei.com>
> Signed-off-by: Libo Chen <chenlibo@huawei.com>
> Signed-off-by: Weilong Chen <chenweilong@huawei.com>

Applied to net-next, thanks.
