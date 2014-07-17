From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
Date: Wed, 16 Jul 2014 22:24:15 -0700 (PDT)
Message-ID: <20140716.222415.728402505581829764.davem@davemloft.net>
References: <20140716.202945.2231269352453909430.davem@davemloft.net>
	<1405569340-31507-1-git-send-email-michel@daenzer.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nic_swsd@realtek.com, romieu@fr.zoreil.com, hayeswang@realtek.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michel@daenzer.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405569340-31507-1-git-send-email-michel@daenzer.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Michel D=E4nzer <michel@daenzer.net>
Date: Thu, 17 Jul 2014 12:55:40 +0900

> The ethernet port on my ASUS A88X Pro mainboard stopped working
> several times a day, with messages like these in dmesg:
>=20
> AMD-Vi: Event logged [IO_PAGE_FAULT device=3D05:00.0 domain=3D0x001e =
address=3D0x0000000000003000 flags=3D0x0050]
>=20
> Searching the web for these messages led me to similar reports about
> different hardware supported by r8169, and eventually to commits
> 3ced8c955e74d319f3e3997f7169c79d524dfd06 ('r8169: enforce RX_MULTI_EN
> for the 8168f.') and eb2dc35d99028b698cdedba4f5522bc43e576bd2 ('r8169=
:
> RxConfig hack for the 8168evl'). So I tried this change, and it fixes
> the problem for me.
>=20
> Signed-off-by: Michel D=E4nzer <michel@daenzer.net>
> ---
>=20
> v2: Updated commit log, how about this?

Works for me, applied, thanks.
