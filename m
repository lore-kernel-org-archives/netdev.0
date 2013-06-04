From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: emaclite: include linux/of_irq.h
Date: Tue, 04 Jun 2013 10:46:55 +0200
Message-ID: <51ADA97F.2010308@monstr.eu>
References: <2244203.EL457oABTU@wuerfel> <51ADA36D.7070607@monstr.eu> <2240834.ApHHSrFxQG@wuerfel>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2FHDRMAWBXMTGTGBFVAMI"
Cc: monstr@monstr.eu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:35118 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751415Ab3FDIq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 04:46:59 -0400
Received: by mail-wg0-f54.google.com with SMTP id j13so4194420wgh.9
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 01:46:57 -0700 (PDT)
In-Reply-To: <2240834.ApHHSrFxQG@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2FHDRMAWBXMTGTGBFVAMI
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/04/2013 10:44 AM, Arnd Bergmann wrote:
> On Tuesday 04 June 2013 10:21:01 Michal Simek wrote:
>> On 06/03/2013 11:39 PM, Arnd Bergmann wrote:
>>> The emaclite driver now calls of_irq_to_resource, which is
>>> declared in linux/of_irq.h. Without this patch, I get a build
>>> error on ARM.
>>
>> What about to just change it to use platform_get_resource()?
>> I will test it.
>=20
> Yes, that would work too. It seems the driver predates the automatic
> generation of resources for IRQs and MMIO registers.
>=20
> If you change the IRQ resource to platform_get_resource, you should
> change the other one as well.

Yep. I have done that changes. Let me test them on real hw
and I will send them soon.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2FHDRMAWBXMTGTGBFVAMI
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGtqX8ACgkQykllyylKDCEpbQCgizJAW3/LhmgEJ1mBp7478dN5
XaYAn23hcWq6XvgUkcczWYvXpYolP+t2
=PsTY
-----END PGP SIGNATURE-----

------enig2FHDRMAWBXMTGTGBFVAMI--
