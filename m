From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH V2 3/3] net: bgmac: use PHY subsystem for initializing PHY
Date: Tue, 31 Jan 2017 19:17:50 +0100
Message-ID: <CACna6rzO8hB9P8zPSVCm_z22kU_LUWK54Mw4fJHVz3yGnwFQnA@mail.gmail.com>
References: <20170131.130429.1477789092223900995.davem@davemloft.net>
 <1daad20f-f794-3c10-d020-fa08dbf228c2@gmail.com> <20170131.131452.553487511329277271.davem@davemloft.net>
 <20170131.131604.1471461660602159004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jon Mason <jon.mason@broadcom.com>,
        Felix Fietkau <nbd@openwrt.org>,
        Network Development <netdev@vger.kernel.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f195.google.com ([74.125.82.195]:35994 "EHLO
        mail-ot0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751616AbdAaSRv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:17:51 -0500
Received: by mail-ot0-f195.google.com with SMTP id 36so42679965otx.3
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 10:17:50 -0800 (PST)
In-Reply-To: <20170131.131604.1471461660602159004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 31 January 2017 at 19:16, David Miller <davem@davemloft.net> wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 31 Jan 2017 13:14:52 -0500 (EST)
>
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Tue, 31 Jan 2017 10:06:34 -0800
>>
>>> On 01/31/2017 10:04 AM, David Miller wrote:
>>>>
>>>> This entire series is being held up because there is still questions a=
bout
>>>> whether this is programming the internal PHYs and therefore whether th=
e
>>>> code should be placed elsewhere.
>>>>
>>>> Can we please move the discussion forward?
>>>
>>> The patches are good as-is, we can resolve the PHY programming later on
>>> when we have figured out the details of the 4749 chip we derailed on.
>>
>> Ok great, series applied, thanks.
>
> Actually, reverted, I get build failures:
>
> [davem@dhcp-10-15-49-210 net-next]$ make -s -j8
>   DESCEND  objtool
> Setup is 17084 bytes (padded to 17408 bytes).
> System is 10211 kB
> CRC 68863231
> Kernel: arch/x86/boot/bzImage is ready  (#139)
> ERROR: "bgmac_alloc" [drivers/net/ethernet/broadcom/bgmac-platform.ko] un=
defined!
> ERROR: "bgmac_alloc" [drivers/net/ethernet/broadcom/bgmac-bcma.ko] undefi=
ned!
> scripts/Makefile.modpost:91: recipe for target '__modpost' failed
> make[1]: *** [__modpost] Error 1
> Makefile:1196: recipe for target 'modules' failed
> make: *** [modules] Error 2

Sorry! :( I'm working on this. Shit, I should have resent this after
adding devm_alloc_etherdev to let kbuild test it.

--=20
Rafa=C5=82
