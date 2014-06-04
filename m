From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: remove some unless free on failure in
 alloc_netdev_mqs()
Date: Tue, 03 Jun 2014 19:19:15 -0700 (PDT)
Message-ID: <20140603.191915.1895849688797601513.davem@davemloft.net>
References: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50909 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753159AbaFDCTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 22:19:16 -0400
In-Reply-To: <1401840715-16375-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue,  3 Jun 2014 17:11:54 -0700

> When we jump to free_pcpu on failure in alloc_netdev_mqs()
> rx and tx queues are not yet allocated, so no need to free them.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Looks good, applied, thanks.
