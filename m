From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] net: smsc911x: If PHY doesn't have an interrupt then POLL
Date: Wed, 15 Jun 2016 00:24:33 +0300
Message-ID: <caa45a64-47de-4466-0923-de51a8a8d26a@cogentembedded.com>
References: <1465920962-24946-1-git-send-email-jeremy.linton@arm.com>
 <46b56679-e92a-a8f9-f290-f67495169bdc@cogentembedded.com>
 <5760701F.6000204@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net
To: Jeremy Linton <jeremy.linton@arm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:34033 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932087AbcFNVYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 17:24:37 -0400
Received: by mail-lb0-f177.google.com with SMTP id oe3so443224lbb.1
        for <netdev@vger.kernel.org>; Tue, 14 Jun 2016 14:24:36 -0700 (PDT)
In-Reply-To: <5760701F.6000204@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/14/2016 11:59 PM, Jeremy Linton wrote:

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
>
>     Looks like your phy ends up polling (-1==IRQ_POLL)...

    Yeah. You didn't answer my question though...

>>     I'm using the device tree on my board.
>
>     This was DT as well with a recent fedora/NetworkManager. It actually seems
> to be timing related to how fast the device gets configured after the initial
> phy probe. There is something like a 1 second window or so where it will work,
> but if network manager takes longer than that, the link state drops and cannot
> be brought back up unless the cable is pulled, replugged while the netdevice
> is being restarted.

    1 second is the PHY poll interval IIRC.

MBR, Sergei
