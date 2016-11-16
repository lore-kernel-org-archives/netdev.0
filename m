From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/phy/vitesse: Configure RGMII skew on VSC8601, if
 needed
Date: Tue, 15 Nov 2016 22:12:17 -0500 (EST)
Message-ID: <20161115.221217.2076182289174952941.davem@davemloft.net>
References: <20161114.161818.1460191406108019273.davem@davemloft.net>
        <d567c69f-6b57-7083-9090-df01fb140e36@gmail.com>
        <c9c60bc8-d93f-a60c-7f25-4cd508507e65@adaptrum.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, gokhan@adaptrum.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: alex.g@adaptrum.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <c9c60bc8-d93f-a60c-7f25-4cd508507e65@adaptrum.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alex <alex.g@adaptrum.com>
Date: Mon, 14 Nov 2016 13:54:57 -0800

> 
> 
> On 11/14/2016 01:25 PM, Florian Fainelli wrote:
>> On 11/14/2016 01:18 PM, David Miller wrote:
>>> From: Alexandru Gagniuc <alex.g@adaptrum.com>
>>> Date: Sat, 12 Nov 2016 15:32:13 -0800
>>>
>>>> +	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_ID)
>>>> +		ret = vsc8601_add_skew(phydev);
>>>
>>> I think you should use phy_interface_is_rgmii() here.
>>>
>>
>> This would include all RGMII modes, here I think the intent is to
>> check
>> for PHY_INTERFACE_MODE_RGMII_ID and PHY_INTERFACE_MODE_RGMII_TXID (or
>> RXID),
> 
> That is correct.
> 
>>  Alexandru, what direction does the skew settings apply to?
> 
> It applies a skew in both TX and RX directions.

Please repost your patch, making the intent clear either in the
commit message or a code comment.

Thanks.
