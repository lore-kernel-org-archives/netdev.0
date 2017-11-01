From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: Avoid calling
 platform_device_put() twice in bcmgenet_mii_exit()
Date: Wed, 01 Nov 2017 11:56:56 +0900 (KST)
Message-ID: <20171101.115656.933060478556735217.davem@davemloft.net>
References: <1509167146-93171-1-git-send-email-weiyongjun1@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opendmb@gmail.com, f.fainelli@gmail.com, netdev@vger.kernel.org
To: weiyongjun1@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44398 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdKAC47 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:56:59 -0400
In-Reply-To: <1509167146-93171-1-git-send-email-weiyongjun1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>
Date: Sat, 28 Oct 2017 05:05:46 +0000

> Remove platform_device_put() call after platform_device_unregister()
> from function bcmgenet_mii_exit(), otherwise, we will call
> platform_device_put() twice.
> 
> Fixes: 9a4e79697009 ("net: bcmgenet: utilize generic Broadcom UniMAC
> MDIO controller driver")
> Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>

Applied, thank you.
