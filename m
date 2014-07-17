From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
Date: Wed, 16 Jul 2014 20:29:45 -0700 (PDT)
Message-ID: <20140716.202945.2231269352453909430.davem@davemloft.net>
References: <20140715215412.GA19363@electric-eye.fr.zoreil.com>
	<20140716.152517.952351917803362794.davem@davemloft.net>
	<53C71F1F.8040607@daenzer.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: romieu@fr.zoreil.com, hayeswang@realtek.com, nic_swsd@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michel@daenzer.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53C71F1F.8040607@daenzer.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Michel D=E4nzer <michel@daenzer.net>
Date: Thu, 17 Jul 2014 09:55:59 +0900

> On 17.07.2014 07:25, David Miller wrote:
>> From: Francois Romieu <romieu@fr.zoreil.com>
>> Date: Tue, 15 Jul 2014 23:54:12 +0200
>>=20
>>> Hayes Wang <hayeswang@realtek.com> :
>>>>  Michel D?nzer [mailto:michel@daenzer.net]=20
>>> [...]
>>>>> Without this, the ethernet port on my ASUS A88X Pro mainboard sto=
ps
>>>>> working sometimes, with messages like these in dmesg:
>>>>>
>>>>> AMD-Vi: Event logged [IO_PAGE_FAULT device=3D05:00.0=20
>>>>> domain=3D0x001e address=3D0x0000000000003000 flags=3D0x0050]
>>>>
>>>> I search the information about your issue. It seems to be
>>>> relative to the IOMMU. I don't sure if your patch is the root
>>>> cause or a workaround.
>>>
>>> Btw, a few extra identifiers in rtl_init_rxcfg may improve consiste=
ncy:
>>>
>>>            missing             |          included
>>> -------------------------------+-------------------------------
>>> RTL_GIGA_MAC_VER_36 (8168f)    | RTL_GIGA_MAC_VER_35 (8168f)
>>> RTL_GIGA_MAC_VER_38 (RTL8411)  | RTL_GIGA_MAC_VER_44 (RTL8411)
>>> RTL_GIGA_MAC_VER_39 (RTL8106e) | RTL_GIGA_MAC_VER_43 (RTL8106e)
>>> RTL_GIGA_MAC_VER_37 (RTL8402)  |
>>=20
>> Michel please take Francois's feedback here into consideration and a=
lso
>> provide a more detailed commit message so other people reading the c=
ommit
>> can understand your reasoning for making this change, not just what =
the
>> result might be for making it.
>=20
> I'm afraid I can't do that. I don't really understand any of this stu=
ff,
> I just googled the IOMMU event message, found similar patches for oth=
er
> chipsets, and adapted them for my mainboard until the problem stopped=
=2E

And if so, that's exactly what I want you to say in the commit message.
