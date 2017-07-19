From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: make dev_close void
Date: Wed, 19 Jul 2017 16:42:38 -0700 (PDT)
Message-ID: <20170719.164238.1674311177016256652.davem@davemloft.net>
References: <20170718225927.15944-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yisen.zhuang@huawei.com, salil.mehta@huawei.com,
        marcel@holtmann.org, gustavo@padovan.org, johan.hedberg@gmail.com,
        netdev@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        sthemmin@microsoft.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49174 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932120AbdGSXmj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 19:42:39 -0400
In-Reply-To: <20170718225927.15944-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Tue, 18 Jul 2017 15:59:24 -0700

> Noticed while working on other changes. Why is dev_close()
> returning int, it should be void.  Should also change
> ndo_close to be void, but that requires more work and someone
> with more coccinelle foo (smpl) than me.

Series applied, thanks.
