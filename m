From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 0/3] net: hns: bug fix for HNS driver
Date: Mon, 24 Apr 2017 12:24:48 -0400 (EDT)
Message-ID: <20170424.122448.1775404720510848518.davem@davemloft.net>
References: <1492760684-117205-1-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: salil.mehta@huawei.com, yisen.zhuang@huawei.com,
        lipeng321@huawei.com, huangdaode@hisilicon.com,
        zhouhuiru@huawei.com, netdev@vger.kernel.org,
        charles.chenxin@huawei.com, linuxarm@huawei.com
To: yankejian@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1173436AbdDXQYu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 12:24:50 -0400
In-Reply-To: <1492760684-117205-1-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yankejian <yankejian@huawei.com>
Date: Fri, 21 Apr 2017 15:44:41 +0800

> From: lipeng <lipeng321@huawei.com>
> 
> This series adds support defered probe when mdio or mbigen module
> insmod behind HNS driver, and fixes a bug that a skb has been
> freed, but it may be still used in driver.
> 
> change log:
> V1 -> V2:
> 1. Return appropriate errno in hns_mac_register_phy;

At a minimum you're going to have to expand your commit message in
patch #1 so that it has more detail and explains the situation better.
