From: Yunsheng Lin <linyunsheng@huawei.com>
Subject: Re: [PATCH net-next 1/2] mqprio: Add a new hardware offload type in
 mqprio
Date: Fri, 13 Oct 2017 10:12:38 +0800
Message-ID: <7d1bb860-16c2-3ed6-7f18-d1366ff709d6@huawei.com>
References: <1507775912-22402-1-git-send-email-linyunsheng@huawei.com>
 <1507775912-22402-2-git-send-email-linyunsheng@huawei.com>
 <AM0PR0502MB3683208C0F411F67C70BF6B1BF4B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
        "liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
        "Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
        "gabriele.paoloni@huawei.com" <gabriele.paoloni@huawei.com>,
        "john.garry@huawei.com" <john.garry@huawei.com>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>,
        "salil.mehta@huawei.com" <salil.mehta@huawei.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Yuval Mintz <yuvalm@mellanox.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM0PR0502MB3683208C0F411F67C70BF6B1BF4B0@AM0PR0502MB3683.eurprd05.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Yuval

On 2017/10/13 4:10, Yuval Mintz wrote:
>> When a driver supports both dcb and hardware offloaded mqprio, and
>> user is running mqprio and dcb tool concurrently, the configuration
>> set by each tool may be conflicted with each other because the dcb
> (for second 'each') s/each/the
> 

Will do, Thanks

>> and mqprio may be using the same hardwere offload component and share
> s/hardwere/hardware

Will do, Thanks

> 
>> the tc system in the network stack.
>>
>> This patch adds a new offload type to indicate that the underlying
>> driver offload prio mapping as part of DCB. If the driver would be
> 'should' offload

Will do, Thanks

> 
>> incapable of that it would refuse the offload. User would then have
>> to explicitly request that qdisc offload.
> 
> 
> 
