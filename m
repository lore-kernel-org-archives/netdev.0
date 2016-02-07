From: "Andrew F. Davis" <afd@ti.com>
Subject: Re: [PATCH] net: phy: dp83848: Add support for TI TLK10x Ethernet
 PHYs
Date: Sun, 7 Feb 2016 10:45:41 -0600
Message-ID: <56B774B5.70603@ti.com>
References: <1454713996-28851-1-git-send-email-afd@ti.com>
 <56B664E7.4040202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:55355 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751070AbcBGQpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Feb 2016 11:45:44 -0500
In-Reply-To: <56B664E7.4040202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/06/2016 03:25 PM, Florian Fainelli wrote:
> Le 05/02/2016 15:13, Andrew F. Davis a =C3=A9crit :
>> The TI TLK10x Ethernet PHYs are similar in the interrupt relevant
>> registers and so are compatible with the DP83848x devices already
>> supported. Add these and re-order code to support additional PHYs.
>
> This looks fine, but this could also be broken down into 3 commits:
>
> - one which adds the macro to add new PHY entries
> - one which renames DP83848_PHY_ID to DP83848C_PHY_ID
> - one which factors out the interrupt enable mask
>

No problem, will do.

>>
>> Signed-off-by: Andrew F. Davis <afd@ti.com>
>> ---
>>   drivers/net/phy/dp83848.c | 89 ++++++++++++++++++++++++++++-------=
------------
>>   1 file changed, 53 insertions(+), 36 deletions(-)
>>
>> diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
>> index 5e14e62..bc88259 100644
>> --- a/drivers/net/phy/dp83848.c
>> +++ b/drivers/net/phy/dp83848.c
>> @@ -1,7 +1,8 @@
>>   /*
>>    * Driver for the Texas Instruments DP83848 PHY
>>    *
>> - * Copyright (C) 2015 Texas Instruments Inc.
>> + * Copyright (C) 2015-2016 Texas Instruments Incorporated - http://=
www.ti.com/
>> + *	Andrew F. Davis <afd@ti.com>
>
> We have the git changelog to know who added changes to the driver, yo=
u
> can drop that specific change and just bump the copyright year.

I was the original author and forgot to add this, just like the consist=
ency
with other drivers with named authors, but not a big deal so I can drop=
 that.

Andrew

> --
> Florian
>
