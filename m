From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: addrconf: Avoid addrconf_disable_change() using
 RCU read-side lock
Date: Thu, 19 Jan 2017 11:09:46 -0500 (EST)
Message-ID: <20170119.110946.2012674581809955045.davem@davemloft.net>
References: <1484814381-61150-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, dingtianhong@huawei.com,
        weiyongjun1@huawei.com, guohanjun@huawei.com
To: wangkefeng.wang@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59094 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753415AbdASQUt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 11:20:49 -0500
In-Reply-To: <1484814381-61150-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kefeng Wang <wangkefeng.wang@huawei.com>
Date: Thu, 19 Jan 2017 16:26:21 +0800

> Just like commit 4acd4945cd1e ("ipv6: addrconf: Avoid calling
> netdevice notifiers with RCU read-side lock"), it is unnecessary
> to make addrconf_disable_change() use RCU iteration over the
> netdev list, since it already holds the RTNL lock, or we may meet
> Illegal context switch in RCU read-side critical section.
> 
> Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>

Applied and queued up for -stable, thanks.
