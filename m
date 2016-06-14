From: Jeremy Linton <jeremy.linton@arm.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Tue, 14 Jun 2016 16:40:12 -0500
Message-ID: <576079BC.8010802@arm.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
 <57607742.5080208@arm.com>
 <308d1da5-a869-7664-e5b4-0c838d9d2c60@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from foss.arm.com ([217.140.101.70]:33454 "EHLO foss.arm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750771AbcFNVkO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 17:40:14 -0400
In-Reply-To: <308d1da5-a869-7664-e5b4-0c838d9d2c60@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 04:34 PM, Sergei Shtylyov wrote:
> On 06/15/2016 12:29 AM, Jeremy Linton wrote:
>
>>>> If the interrupt configuration isn't set and we are using the
>>>
>>>     It's never set, judging by the driver code.
>>>
>>>> internal phy, then we need to poll the phy to reliably detect
>>>> phy state changes.
>>>
>>>     What address your internal PHY is at? Mine is at 1, and things seem
>>> to work reliably after probing:
>>>
>>> SMSC LAN8700 18000000.etherne:01: attached PHY driver [SMSC LAN8700]
>>> (mii_bus:phy_addr=18000000.etherne:01, irq=-1)
>>>
>>>     I'm using the device tree on my board.
>>
>> Ok, I'm back on the machine, this is what mine says without that patch.
>>
>>
>>
>> SMSC LAN911x Internal PHY 18000000.etherne:01: attached PHY driver [SMSC
>> LAN911x Internal PHY] (mii_bus:phy_addr=18000000.etherne:01, irq=0)
>
>     Hum, that's unexpected... things are probably more complex that I
> thought. Do you have extra patches to this driver by changce?

No, the initial kernel where the problem was discovered is
4.5.2-301.fc24.aarch64, but I built a mainline 4.6, and modprobed the 
driver with the same effect.


Although, now that I'm looking closer at phy_irq, I'm curious how it 
works for anyone else...
