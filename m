From: Weidong Wang <wangweidong1@huawei.com>
Subject: Re: [PATCH net-next v2] bgmac: fix a missing check for build_skb
Date: Thu, 14 Jan 2016 10:10:58 +0800
Message-ID: <569703B2.1030808@huawei.com>
References: <5695BF41.2040002@huawei.com> <56963AA3.2010804@huawei.com> <1452696749.1223.60.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <nbd@openwrt.org>,
	<zajec5@gmail.com>, <hauke@hauke-m.de>,
	Joe Perches <joe@perches.com>, <peter.senna@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Paolo Abeni <pabeni@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452696749.1223.60.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2016/1/13 22:52, Eric Dumazet wrote:
> On Wed, 2016-01-13 at 19:53 +0800, Weidong Wang wrote:
>> when build_skb failed, it may occur a NULL pointer.
>> So add a 'NULL check' for it.
>>
>> Signed-off-by: Weidong Wang <wangweidong1@huawei.com>
>> ---
>> change log:
>> v2:
>>  fix the error logic change which pointed by Paolo Abni
>>  and Felix.
> 
> This is too late, you have to send a relative patch, since the prior one
> was merged.
> 
> 
OK.

Regards,
Weidong

> 
> 
