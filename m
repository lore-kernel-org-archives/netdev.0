From: Hayes Wang <hayeswang@realtek.com>
Subject: RE: [PATCH] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
Date: Tue, 15 Jul 2014 09:29:39 +0000
Message-ID: <0835B3720019904CB8F7AA43166CEEB25066DC@RTITMBSV03.realtek.com.tw>
References: <1405406500-1208-1-git-send-email-michel@daenzer.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: =?iso-8859-1?Q?Michel_D=E4nzer?= <michel@daenzer.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	nic_swsd <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:56412 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756689AbaGOJaA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2014 05:30:00 -0400
In-Reply-To: <1405406500-1208-1-git-send-email-michel@daenzer.net>
Content-Language: zh-TW
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 Michel D=E4nzer [mailto:michel@daenzer.net]=20
> Sent: Tuesday, July 15, 2014 2:42 PM
> To: Francois Romieu; nic_swsd
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [PATCH] r8169: Enable RX_MULTI_EN for RTL_GIGA_MAC_VER_40
>=20
> Without this, the ethernet port on my ASUS A88X Pro mainboard stops
> working sometimes, with messages like these in dmesg:
>=20
> AMD-Vi: Event logged [IO_PAGE_FAULT device=3D05:00.0=20
> domain=3D0x001e address=3D0x0000000000003000 flags=3D0x0050]

I search the information about your issue. It seems to be
relative to the IOMMU. I don't sure if your patch is the root
cause or a workaround.
=20
Best Regards,
Hayes
