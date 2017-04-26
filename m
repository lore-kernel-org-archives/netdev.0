From: "lipeng (Y)" <lipeng321@huawei.com>
Subject: Re: [PATCH net v2 0/3] net: hns: bug fix for HNS driver
Date: Wed, 26 Apr 2017 11:05:33 +0800
Message-ID: <2bab226c-4fba-32bf-ead7-dd397293879f@huawei.com>
References: <1492760684-117205-1-git-send-email-yankejian@huawei.com>
 <20170424.122448.1775404720510848518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <huangdaode@hisilicon.com>, <zhouhuiru@huawei.com>,
        <netdev@vger.kernel.org>, <charles.chenxin@huawei.com>,
        <linuxarm@huawei.com>
To: David Miller <davem@davemloft.net>, <yankejian@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga05-in.huawei.com ([45.249.212.191]:2074 "EHLO
        dggrg05-dlp.huawei.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1432939AbdDZDHA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 23:07:00 -0400
In-Reply-To: <20170424.122448.1775404720510848518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017/4/25 0:24, David Miller wrote:
> From: Yankejian <yankejian@huawei.com>
> Date: Fri, 21 Apr 2017 15:44:41 +0800
>
>> From: lipeng <lipeng321@huawei.com>
>>
>> This series adds support defered probe when mdio or mbigen module
>> insmod behind HNS driver, and fixes a bug that a skb has been
>> freed, but it may be still used in driver.
>>
>> change log:
>> V1 -> V2:
>> 1. Return appropriate errno in hns_mac_register_phy;
> At a minimum you're going to have to expand your commit message in
> patch #1 so that it has more detail and explains the situation better.
> .
OK, will add more detail and explains for #1 patch.

thanks
