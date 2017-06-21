From: l00371289 <linyunsheng@huawei.com>
Subject: Re: [PATCH NET] net/hns:bugfix of ethtool -t phy self_test
Date: Wed, 21 Jun 2017 10:06:10 +0800
Message-ID: <199ec218-f7ab-4c6a-5896-e34bce262481@huawei.com>
References: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
 <7500513f-e263-838c-12a1-4343f7281f1a@gmail.com>
 <20170619215435.GA13704@lunn.ch>
 <f526345d-b0a4-1c45-8472-81c6c548950c@huawei.com>
 <20170620132857.GE13704@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, <davem@davemloft.net>,
        <huangdaode@hisilicon.com>, <xuwei5@hisilicon.com>,
        <liguozhu@hisilicon.com>, <Yisen.Zhuang@huawei.com>,
        <gabriele.paoloni@huawei.com>, <john.garry@huawei.com>,
        <linuxarm@huawei.com>, <salil.mehta@huawei.com>,
        <lipeng321@huawei.com>, <yankejian@huawei.com>,
        <tremyfr@gmail.com>, <xieqianqian@huawei.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170620132857.GE13704@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Andrew

On 2017/6/20 21:28, Andrew Lunn wrote:
>>>> The question really is, why is not this properly integrated into the PHY
>>>> driver and PHYLIB such that the only thing the Ethernet MAC driver has
>>>> to call is a function of the PHY driver putting it in self-test?
>>>
>>> This whole driver pokes various PHY registers, rather than use
>>> phylib. And it does so without taking the PHY lock. 
>> I will consider using phylib as much as possible, thanks.
>>
>> It also assumes it
>>> is a Marvell PHY and i don't see anywhere it actually verifies this.
>> When it said Marvell Phy , I meant Marvell Phy with fibre support.
>> I will send anther patch to only setting bit in Fiber Control when
>> it is a Marvell Phy with fibre support.
> 
> There is a lot more broken than just that.
> 
> You really should remove all code which is accessing the PHY, and add
> support to phylib and the drivers for what you need.
> 
>     Andrew
After adding genphy_loopback support, I will try it. Thanks for pointing out.

Best Regards
Yunsheng Lin
