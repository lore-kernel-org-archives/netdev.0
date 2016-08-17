From: John Fleming <john@spikefishsolutions.com>
Subject: Re: DSA + Marvell embedded switch question
Date: Tue, 16 Aug 2016 22:41:00 -0400
Message-ID: <CABy3cGwqWkX4Uij0cwqBT9xwU8mQDzpnhXK4mm98jBeMzRG5RA@mail.gmail.com>
References: <CABy3cGyiS7ZqcuKiYkPKWFM3kOph_Yw1bpR+x1cO-5W+Zh4+Uw@mail.gmail.com>
 <20160816181749.GQ14446@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f42.google.com ([74.125.82.42]:37963 "EHLO
	mail-wm0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751284AbcHQCsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 22:48:16 -0400
Received: by mail-wm0-f42.google.com with SMTP id o80so205049329wme.1
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 19:48:15 -0700 (PDT)
In-Reply-To: <20160816181749.GQ14446@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 16, 2016 at 2:17 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Mon, Aug 15, 2016 at 08:17:24PM -0400, John Fleming wrote:
>> Hi all, I have a embedded appliance I bought from a vendor and i'm
>> being told to file a RFE for this.
>>
>> The issue i have is the device has a embedded Marvell switch (88E1514
>> ?).
>
> Hi John
>
> 1514 is probably a PHY, not a switch. All switches are 88E6XXX.
>

I thought this might be the case from poking around Marvell's website.

>> LAN1 through LAN6 are part of a single bridge group by default.
>> Not sure if that is the correct term because i don't think it was
>> created via brctl and doesn't show up in there.
>>
>> This is what ethtool shows as the driver. Looks like the driver name
>> is marvellmod based on lsmod output.
>>
>> ethtool -i LAN1
>> driver: marvell switch port
>> version: 1.0
>> firmware-version:
>> bus-info: switch SMI bus
>> supports-statistics: no
>> supports-test: no
>> supports-eeprom-access: no
>> supports-register-dump: no
>> supports-priv-flags: no
>>
>> Also found this
>> crw-r--r--    1 root     root      10,   3 Aug 15 17:49 /dev/marvell
>
> These all tell me it is using some proprietary driver, not mainline
> Linux code.
>

I wondered this as well. I poked around the source tree a bit before
asking here.

>> Just wondering if anyone can point me to something that could pull
>> this information. I don't have any C know how, but if nudged in the
>> right direction i think i could figure it out.
>
> You probably need to contact Marvell and ask them about their
> proprietary code. We here don't have access to it.
>
>             Andrew

Well, thanks for taking the time to look.I did register on Marvell's website,
however i'm pretty sure that won't go anywhere.

Anyway, thanks again!
