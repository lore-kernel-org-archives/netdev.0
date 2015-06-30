From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] COLO Proxy Module
Date: Tue, 30 Jun 2015 11:19:05 +0200
Message-ID: <20150630091905.GF17501@acer.localdomain>
References: <5582673B.3010804@cn.fujitsu.com>
 <55924787.3060203@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pablo@netfilter.org,
	kadlec@blackhole.kfki.hu, davem@davemloft.net,
	coreteam@netfilter.org, Yang Hongyang <yanghy@cn.fujitsu.com>,
	=?utf-8?B?5ripIOS7jua0iw==?= <wency@cn.fujitsu.com>,
	zhanghailiang <zhang.zhanghailiang@huawei.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	"peter.huangpeng" <peter.huangpeng@huawei.com>,
	"Gonglei (Arei)" <arei.gonglei@huawei.com>
To: Li Zhijian <lizhijian@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <55924787.3060203@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30.06, Li Zhijian wrote:
> |ping...
> 
> and i have another question:
> can i add a new |||nf_ct_ext_id simply without touching the exiting kernel
> code?|

No, the kernel needs to know the highest extension ID in order to
allocate space for the offsets.

> in order to support COLO-Proxy, i need a extra nf_ct_ext_id called
> "NF_CT_EXT_COLO"
> to store some message of COLO related. This message can help COLO-Proxy to
> buffer packet and compare packet for each connection.
> 
> Thanks
> Li Zhijian

Cheers,
Patrick
