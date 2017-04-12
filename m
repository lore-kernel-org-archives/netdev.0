From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] devlink: fix return value check in
 devlink_dpipe_header_put()
Date: Tue, 11 Apr 2017 23:03:28 -0400 (EDT)
Message-ID: <20170411.230328.1122763321161603727.davem@davemloft.net>
References: <20170410131106.27683-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, arkadis@mellanox.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39442 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752002AbdDLDDa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 23:03:30 -0400
In-Reply-To: <20170410131106.27683-1-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 10 Apr 2017 13:11:06 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix the retrn value check which testing the wrong variable
> in devlink_dpipe_header_put().
> 
> Fixes: 1555d204e743 ("devlink: Support for pipeline debug (dpipe)")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

This doesn't apply cleanly to net-next, please respin and also fix
the typo in your commit message as pointed out by Jiri.
