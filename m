From: =?windows-1252?Q?Michel_D=E4nzer?= <michel@daenzer.net>
Subject: Re: [PATCH] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
Date: Tue, 15 Jul 2014 18:56:41 +0900
Message-ID: <53C4FAD9.1020008@daenzer.net>
References: <1405406500-1208-1-git-send-email-michel@daenzer.net> <0835B3720019904CB8F7AA43166CEEB25066DC@RTITMBSV03.realtek.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	nic_swsd <nic_swsd@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0835B3720019904CB8F7AA43166CEEB25066DC@RTITMBSV03.realtek.com.tw>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.07.2014 18:29, Hayes Wang wrote:
>  Michel D=E4nzer [mailto:michel@daenzer.net]=20
>> Sent: Tuesday, July 15, 2014 2:42 PM
>> To: Francois Romieu; nic_swsd
>> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
>> Subject: [PATCH] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
>>
>> Without this, the ethernet port on my ASUS A88X Pro mainboard stops
>> working sometimes, with messages like these in dmesg:
>>
>> AMD-Vi: Event logged [IO_PAGE_FAULT device=3D05:00.0=20
>> domain=3D0x001e address=3D0x0000000000003000 flags=3D0x0050]
>=20
> I search the information about your issue. It seems to be
> relative to the IOMMU. I don't sure if your patch is the root
> cause or a workaround.

It's quite possibly just a workaround; I tried this based on previous
similar commits in this driver.


--=20
Earthling Michel D=E4nzer            |                  http://www.amd.=
com
Libre software enthusiast          |                Mesa and X develope=
r
