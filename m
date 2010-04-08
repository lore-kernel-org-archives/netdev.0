From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree
Date: Fri, 9 Apr 2010 08:59:18 +1000
Message-ID: <20100409085918.cc984fb1.sfr@canb.auug.org.au>
References: <20100408153505.eb205158.sfr@canb.auug.org.au>
	<20100407.232500.184442638.davem@davemloft.net>
	<6125d80a-81d5-4699-ac6e-9408bd0c1145@SG2EHSMHS010.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__9_Apr_2010_08_59_18_+1000_/czZ1g_0yUPRmo6+"
Cc: "David Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-next@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<jtyner@cs.ucr.edu>, <grant.likely@secretlab.ca>
To: John Linn <John.Linn@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6125d80a-81d5-4699-ac6e-9408bd0c1145@SG2EHSMHS010.ehs.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__9_Apr_2010_08_59_18_+1000_/czZ1g_0yUPRmo6+
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

On Thu, 8 Apr 2010 08:15:12 -0600 John Linn <John.Linn@xilinx.com> wrote:
>
> I'm not pushing back here, just trying to make sure I understand and do
> it better next time :)
>=20
> I don't see that my patch has touched that part of the driver as that
> call was already in the driver before my patch (but maybe I'm just
> missing it).
>=20
> My patch did change the dependency in the Kconfig so that it only
> depends on powerpc rather than powerpc DCR and maybe that exposed
> something that wasn't previously exposed.

Yeah, virt_to_bus() is only defined on 32bit PowerPC, not 64 bit.

CONFIG_PPC is set for both 32 and 64 bit PowerPC builds.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__9_Apr_2010_08_59_18_+1000_/czZ1g_0yUPRmo6+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAku+X8YACgkQjjKRsyhoI8y32ACeOsJXHXLdFZ2R4RVgAQ/OyKLO
4OoAn2Sr376br6xqoZ7liapSeWtO1YPs
=HxCw
-----END PGP SIGNATURE-----

--Signature=_Fri__9_Apr_2010_08_59_18_+1000_/czZ1g_0yUPRmo6+--
