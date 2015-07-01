From: Wen Congyang <wency@cn.fujitsu.com>
Subject: Re: [RFC] COLO Proxy Module
Date: Wed, 1 Jul 2015 18:57:11 +0800
Message-ID: <5593C787.3070005@cn.fujitsu.com>
References: <5582673B.3010804@cn.fujitsu.com> <55924787.3060203@cn.fujitsu.com> <20150630091905.GF17501@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netfilter-devel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <pablo@netfilter.org>,
	<kadlec@blackhole.kfki.hu>, <davem@davemloft.net>,
	<coreteam@netfilter.org>, Yang Hongyang <yanghy@cn.fujitsu.com>,
	zhanghailiang <zhang.zhanghailiang@huawei.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	"peter.huangpeng" <peter.huangpeng@huawei.com>,
	"Gonglei (Arei)" <arei.gonglei@huawei.com>
To: Patrick McHardy <kaber@trash.net>,
	Li Zhijian <lizhijian@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150630091905.GF17501@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/30/2015 05:19 PM, Patrick McHardy wrote:
> On 30.06, Li Zhijian wrote:
>> |ping...
>>
>> and i have another question:
>> can i add a new |||nf_ct_ext_id simply without touching the exiting kernel
>> code?|
> 
> No, the kernel needs to know the highest extension ID in order to
> allocate space for the offsets.

So if we want to add a new extension, we should post the module too. Is
it right?

Thanks
Wen Congyang

> 
>> in order to support COLO-Proxy, i need a extra nf_ct_ext_id called
>> "NF_CT_EXT_COLO"
>> to store some message of COLO related. This message can help COLO-Proxy to
>> buffer packet and compare packet for each connection.
>>
>> Thanks
>> Li Zhijian
> 
> Cheers,
> Patrick
> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-devel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> .
> 

