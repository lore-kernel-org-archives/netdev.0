From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Wed, 15 Jun 2016 00:34:10 +0300
Message-ID: <308d1da5-a869-7664-e5b4-0c838d9d2c60@cogentembedded.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
 <57607742.5080208@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:34972 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751488AbcFNVeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:34:14 -0400
Received: by mail-lb0-f177.google.com with SMTP id o4so561527lbp.2
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 14:34:13 -0700 (PDT)
In-Reply-To: <57607742.5080208@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/2016 12:29 AM, Jeremy Linton wrote:

>>> If the interrupt configuration isn't set and we are using the
>>
>>     It's never set, judging by the driver code.
>>
>>> internal phy, then we need to poll the phy to reliably detect
>>> phy state changes.
>>
>>     What address your internal PHY is at? Mine is at 1, and things seem
>> to work reliably after probing:
>>
>> SMSC LAN8700 18000000.etherne:01: attached PHY driver [SMSC LAN8700]
>> (mii_bus:phy_addr=18000000.etherne:01, irq=-1)
>>
>>     I'm using the device tree on my board.
>
> Ok, I'm back on the machine, this is what mine says without that patch.
>
>
>
> SMSC LAN911x Internal PHY 18000000.etherne:01: attached PHY driver [SMSC
> LAN911x Internal PHY] (mii_bus:phy_addr=18000000.etherne:01, irq=0)

    Hum, that's unexpected... things are probably more complex that I thought. 
Do you have extra patches to this driver by changce?

MBR, Sergei
