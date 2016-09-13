From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] tipc: fix possible memory leak in
 tipc_udp_enable()
Date: Tue, 13 Sep 2016 11:29:03 -0400 (EDT)
Message-ID: <20160913.112903.594164723942368702.davem@davemloft.net>
References: <1473469015-6180-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, ying.xue@windriver.com,
        richard.alpe@ericsson.com, weiyongjun1@huawei.com,
        netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39908 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753117AbcIMP3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 11:29:04 -0400
In-Reply-To: <1473469015-6180-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Sat, 10 Sep 2016 00:56:55 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> 'ub' is malloced in tipc_udp_enable() and should be freed before
> leaving from the error handling cases, otherwise it will cause
> memory leak.
> 
> Fixes: ba5aa84a2d22 ("tipc: split UDP nl address parsing")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied, thanks.
