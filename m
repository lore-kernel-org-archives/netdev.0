From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] qed: fix invalid use of sizeof in
 qed_alloc_qm_data()
Date: Tue, 25 Apr 2017 12:00:01 -0400 (EDT)
Message-ID: <20170425.120001.190819999818819545.davem@davemloft.net>
References: <20170425070718.14790-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Yuval.Mintz@cavium.com, Ariel.Elior@cavium.com,
        weiyongjun1@huawei.com, everest-linux-l2@cavium.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41208 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951116AbdDYQAD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 12:00:03 -0400
In-Reply-To: <20170425070718.14790-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue, 25 Apr 2017 07:07:18 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> sizeof() when applied to a pointer typed expression gives the
> size of the pointer, not that of the pointed data.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied with Yuval's Fixes: tag added.
