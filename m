From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: qlcnic: fix warning for incorrect
 type in argument
Date: Mon, 13 Jan 2014 23:31:03 -0800 (PST)
Message-ID: <20140113.233103.848993018269167330.davem@davemloft.net>
References: <52D0FF87.4090806@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, rajesh.borundia@qlogic.com,
	netdev@vger.kernel.org, joe@perches.com, julia.lawall@lip6.fr
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41293 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbaANHbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 02:31:04 -0500
In-Reply-To: <52D0FF87.4090806@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Sat, 11 Jan 2014 16:23:35 +0800

> The commit 6878f79a8b71e8c7b0587a1185584f54fd31f185
> (net: qlcnic: slight optimization of addr compare)
> cause a warning "sparse: incorrect type in argument 2
> (different type sizes)", so fix it.
> 
> I think julia will convert ether_addr_equal to ether_addr_equal_64bits later.
> 
> Cc: Himanshu Madhani <himanshu.madhani@qlogic.com>
> Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Applied.
