From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: emac: remove unnecessary dev_set_drvdata()
Date: Fri, 16 Sep 2016 04:26:20 -0400 (EDT)
Message-ID: <20160916.042620.657007205346868546.davem@davemloft.net>
References: <1473906352-2974-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timur@codeaurora.org, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758114AbcIPI0W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 04:26:22 -0400
In-Reply-To: <1473906352-2974-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Thu, 15 Sep 2016 02:25:52 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> The driver core clears the driver data to NULL after device_release
> or on probe failure. Thus, it is not needed to manually clear the
> device driver data to NULL.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
