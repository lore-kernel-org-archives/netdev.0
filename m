From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: [PATCH] skge support for Marvell chips in Toshiba laptops
Date: Thu, 20 Oct 2005 16:50:31 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.0510201645340.20245@bizon.gios.gov.pl>
References: <200510191047.53212.jbarnes@virtuousgeek.org> <4356A1F5.5010200@gentoo.org>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-529191231-1129819831=:20245"
Cc: Jesse Barnes <jbarnes@virtuousgeek.org>, shemminger@osdl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751534AbVJTOut@vger.kernel.org>
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <4356A1F5.5010200@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-529191231-1129819831=:20245
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Wed, 19 Oct 2005, Daniel Drake wrote:

> Hi Jesse,
>
> Jesse Barnes wrote:
>> Here's a small patch to add the PCI ID and chip type of the chip in my=
=20
>> Toshiba laptop to the skge driver.  I haven't tested it much (just insmo=
ded=20
>> it and run ethtool against the corresponding eth1 device), but it doesn'=
t=20
>> crash my system, so unless this configuration has already been tested an=
d=20
>> is known to have problems, it might be good to add this patch.
>>=20
>> I'll test some more with a real network when I get home.
>
> The device ID you added (0x4351) is already claimed by the new sky2 drive=
r.
>
> Unless theres a mistake in sky2's device table, your laptop contains a=20
> Yukon-II adapter which is incompatible with the original Yukon chips (skg=
e =3D=20
> Yukon, sky2 =3D Yukon-II).
>
> On the other hand, I believe Stephen could do with some extra sky2 testin=
g :)
> You can find it in the latest -mm releases.

What is the name of sky2 driver? I can't to find it in:
ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.14-rc4/2.=
6.14-rc4-mm1/broken-out/

Wrong place?

Best regards,

 =09=09=09Krzysztof Ol=EAdzki
---187430788-529191231-1129819831=:20245--
