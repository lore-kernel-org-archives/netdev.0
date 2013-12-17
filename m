From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: Reorder 'struc association' members to reduce
 its size
Date: Tue, 17 Dec 2013 14:32:56 -0500 (EST)
Message-ID: <20131217.143256.233394040400199988.davem@davemloft.net>
References: <52AAA048.2040704@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: wangweidong1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48344 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751332Ab3LQTc5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 14:32:57 -0500
In-Reply-To: <52AAA048.2040704@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Weidong <wangweidong1@huawei.com>
Date: Fri, 13 Dec 2013 13:51:04 +0800

> Members of 'struct association' are not in appropriate order to
> reuse compiler added padding on 64bit architectures. In this patch
> we reorder those struct members and help reduce the size of the
> structure from 2776 bytes to 2720 bytes on 64 bit architectures.
> 
> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>

Applied, thanks.
