From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V2 net-next 20/21] net-next/hinic: Add ethtool and stats
Date: Sun, 30 Jul 2017 12:59:00 +0300
Message-ID: <99112819-c71b-9925-0625-eda024dd6259@huawei.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
 <b66411dd204e8989f58e70bea8ae11d2cbe5cd1b.1500454998.git.aviad.krawczyk@huawei.com>
 <1500460074.25934.33.camel@perches.com>
 <9df7d969-6706-d702-a674-9207f5b1c3df@huawei.com>
 <20170726223327.GG7966@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, <davem@davemloft.net>,
        <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <zhaochen6@huawei.com>, <tony.qu@huawei.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170726223327.GG7966@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I saw that netif_err is more common in code, is it preferred on netdev_err?
What is the preferred style, netif_ or netdev_?

Best Regards,
Aviad

On 7/27/2017 1:33 AM, Andrew Lunn wrote:
> On Wed, Jul 19, 2017 at 03:36:28PM +0300, Aviad Krawczyk wrote:
>> Hi Joe,
>>
>> I tried to be consistent with the comments before, that requested
>> that we will use dev_err exclude some special cases for use netif.
>>
>> We will replace the dev_err(&netdev->dev,.. to netdev_err in the
>> next fix.
> 
> netdev_err() should be used when possible. You just have to be careful
> in the probe() function, before netdev exists and you get "(NULL
> net_device):" or before it is registered and you get "(unnamed
> net_device)" instead of "eth42" etc.
> 
> 	      Andrew
> 
> .
> 
