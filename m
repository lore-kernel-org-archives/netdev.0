From: Weidong Wang <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next] BNX2: fix a Null Pointer for stats_blk
Date: Thu, 24 Sep 2015 14:53:26 +0800
Message-ID: <56039DE6.5020904@huawei.com>
References: <56014CC0.3050201@huawei.com> <20150923.153117.2291008783799112683.davem@davemloft.net> <5603594D.70408@huawei.com> <20150923.223436.53190852255282400.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <sony.chacko@qlogic.com>, <Dept-HSGLinuxNICDev@qlogic.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<rui.xiang@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150923.223436.53190852255282400.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2015/9/24 13:34, David Miller wrote:
> From: Weidong Wang <wangweidong1@huawei.com>
> Date: Thu, 24 Sep 2015 10:00:45 +0800
> 
>> It does affect the intention. Although, the problem exists then makes the
>> system panic within some case.
>>
>> Do you have any idea about it?
> 
> Allocate the statistics block at probe time so that this problem is
> impossible.
> 

It is a good idea.

Yet, what is the intention of the dynamic to alloc/free stats_block?
what will be affected by allocating the statistics block.

Best Regards,
Weidong

> 
