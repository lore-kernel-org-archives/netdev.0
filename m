From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] sctp: remove the never used 'return' and
 redundant 'break'
Date: Sun, 22 Dec 2013 18:57:10 -0500 (EST)
Message-ID: <20131222.185710.599956561344900588.davem@davemloft.net>
References: <52B168E0.1060108@huawei.com>
	<52B253C2.8070407@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53313 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756597Ab3LVX5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 18:57:12 -0500
In-Reply-To: <52B253C2.8070407@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Thu, 19 Dec 2013 10:02:42 +0800

> In switch() had do return, and never use the 'return NULL'. The
> 'break' after return or goto has no effect. Remove it.
> 
> v2: make it more readable as suggested by Neil.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
