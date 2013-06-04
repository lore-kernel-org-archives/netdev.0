From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH] net: emaclite: include linux/of_irq.h
Date: Tue, 04 Jun 2013 10:21:01 +0200
Message-ID: <51ADA36D.7070607@monstr.eu>
References: <2244203.EL457oABTU@wuerfel>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2GGOIMXJELOKLAAWSJRCO"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2244203.EL457oABTU@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2GGOIMXJELOKLAAWSJRCO
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 06/03/2013 11:39 PM, Arnd Bergmann wrote:
> The emaclite driver now calls of_irq_to_resource, which is
> declared in linux/of_irq.h. Without this patch, I get a build
> error on ARM.

What about to just change it to use platform_get_resource()?
I will test it.

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2GGOIMXJELOKLAAWSJRCO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGto20ACgkQykllyylKDCEkiACfUHL50VF0a6Toi/EJ6lJcvrM9
SHsAn3BQVe4amTEYMR0PYkYLVo2KBYwO
=qimI
-----END PGP SIGNATURE-----

------enig2GGOIMXJELOKLAAWSJRCO--
