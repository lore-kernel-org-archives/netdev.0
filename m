From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V4 net-next 21/21] net-next/hinic: Add select_queue and
 netpoll
Date: Thu, 17 Aug 2017 15:46:43 +0300
Message-ID: <44b1896a-01c0-ab0b-ede9-8582edeac9a3@huawei.com>
References: <cover.1502883967.git.aviad.krawczyk@huawei.com>
 <d5f45e39dc7d5ccb0bcb6bd5e2ebea7d6ffaba83.1502883967.git.aviad.krawczyk@huawei.com>
 <20170816.114721.2286909258495579175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <zhaochen6@huawei.com>, <tony.qu@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816.114721.2286909258495579175.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Fixed in V6.
In V5 patch-set there was a problem in cover-letter msg-id.

Thanks,
Aviad

On 8/16/2017 9:47 PM, David Miller wrote:
> From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
> Date: Wed, 16 Aug 2017 20:03:06 +0800
> 
>> +static u16 hinic_select_queue(struct net_device *netdev, struct sk_buff *skb,
>> +			      void *accel_priv,
>> +			      select_queue_fallback_t fallback)
>> +{
>> +	u16 qid;
>> +
>> +	if (skb_rx_queue_recorded(skb))
>> +		qid = skb_get_rx_queue(skb);
>> +	else
>> +		qid = fallback(netdev, skb);
>> +
>> +	return qid;
>> +}
> 
> This is a NOP, do not implement this function unless you absolutely need to
> do something custom in your driver, and you do not.
> 
> .
> 
