From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: don't clear stats while tg3_close
Date: Wed, 03 May 2017 09:54:05 -0400 (EDT)
Message-ID: <20170503.095405.1648539883018022190.davem@davemloft.net>
References: <20170503075132.2648-1-yuehaibing@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, weiyongjun1@huawei.com
To: yuehaibing@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751883AbdECNyH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 09:54:07 -0400
In-Reply-To: <20170503075132.2648-1-yuehaibing@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YueHaibing <yuehaibing@huawei.com>
Date: Wed, 3 May 2017 15:51:32 +0800

> Now tg3 NIC's stats will be cleared after ifdown/ifup. bond_get_stats traverse
> its salves to get statistics,cumulative the increment.If a tg3 NIC is added to
> bonding as a slave,ifdown/ifup will cause bonding's stats become tremendous value
> (ex.1638.3 PiB) because of negative increment.
> 
> Fixes: 92feeabf3f67 ("tg3: Save stats across chip resets")
> Signed-off-by: YueHaibing <yuehaibing@huawei.com>

Indeed, no driver should clear statistics over open/close.

Applied, thanks.
