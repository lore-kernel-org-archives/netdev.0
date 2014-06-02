From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: fix the unbalanced promiscuous count
 when add_if failed
Date: Sun, 01 Jun 2014 22:05:36 -0700 (PDT)
Message-ID: <20140601.220536.2044599890570404047.davem@davemloft.net>
References: <53869842.4060202@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, vyasevic@redhat.com
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56250 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702AbaFBFFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 01:05:37 -0400
In-Reply-To: <53869842.4060202@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Thu, 29 May 2014 10:15:30 +0800

> As commit 2796d0c648c94("bridge: Automatically manage port
> promiscuous mode."), make the add_if use dev_set_allmulti
> instead of dev_set_promiscuous, so when add_if failed, we
> should do dev_set_allmulti(dev, -1).
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thank you.
