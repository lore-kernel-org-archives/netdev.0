From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] genetlink: fix error return code in
 genl_register_family()
Date: Tue, 01 Nov 2016 12:13:51 -0400 (EDT)
Message-ID: <20161101.121351.1287443789684060786.davem@davemloft.net>
References: <1477925583-7956-1-git-send-email-weiyj.lk@gmail.com>
        <1478011552-24957-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, tom@herbertland.com, fw@strlen.de,
        johannes.berg@intel.com, pshelar@ovn.org,
        tycho.andersen@canonical.com, matti.vaittinen@nokia.com,
        weiyongjun1@huawei.com, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47280 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750833AbcKAQNx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:13:53 -0400
In-Reply-To: <1478011552-24957-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Tue,  1 Nov 2016 14:45:52 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> Fix to return a negative error code from the idr_alloc() error handling
> case instead of 0, as done elsewhere in this function.
> 
> Also fix the return value check of idr_alloc() since idr_alloc return
> negative errors on failure, not zero.
> 
> Fixes: 2ae0f17df1cd ("genetlink: use idr to track families")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
> ---
> v1 -> v2: fix the return value check and return idr_alloc's err code

Applied, thanks.
