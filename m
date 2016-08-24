From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] xen-netback: using kfree_rcu() to simplify the
 code
Date: Tue, 23 Aug 2016 17:01:11 -0700 (PDT)
Message-ID: <20160823.170111.1405515637589605266.davem@davemloft.net>
References: <1471906889-20132-1-git-send-email-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wei.liu2@citrix.com, weiyongjun1@huawei.com,
        xen-devel@lists.xenproject.org, netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55919 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752758AbcHXABN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:01:13 -0400
In-Reply-To: <1471906889-20132-1-git-send-email-weiyj.lk@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Mon, 22 Aug 2016 23:01:29 +0000

> From: Wei Yongjun <weiyongjun1@huawei.com>
> 
> The callback function of call_rcu() just calls a kfree(), so we
> can use kfree_rcu() instead of call_rcu() + callback function.
> 
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied.
