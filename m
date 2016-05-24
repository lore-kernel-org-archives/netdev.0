From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [ethtool 0/3][pull request] Intel Wired LAN Driver Updates
 2016-05-03
Date: Tue, 24 May 2016 16:47:11 -0700
Message-ID: <1464133631.2631.35.camel@intel.com>
References: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-o0AX7mYwP7+oVVmFWRre"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com
To: davem@davemloft.net, Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:36028 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752580AbcEXXsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 May 2016 19:48:16 -0400
In-Reply-To: <1462380293-4132-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-o0AX7mYwP7+oVVmFWRre
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-05-04 at 09:44 -0700, Jeff Kirsher wrote:
> This series contains updates to ixgbe in ethtool.
>=20
> Preethi adds missing device IDs and mac_type definitions, also updated
> the display registers for x550, x550em_x/a.=C2=A0=C2=A0Cleaned up the for=
mat string
> storage by taking advantage of "for" loops.
>=20
> The following are changes since commit
> deb1c6613ec14fd828d321e38c7bea45fe559bd5:
> =C2=A0 Release version 4.5.
> and are available in the git repository at:
> =C2=A0 git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/ethtool mas=
ter
>=20
> Preethi Banala (3):
> =C2=A0 ethtool/ixgbe: Add device ID and mac_type definitions
> =C2=A0 ethtool/ixgbe: Correct offsets and support x550, x550em_x, x550em_=
a
> =C2=A0 ethtool/ixgbe: Reduce format string storage
>=20
> =C2=A0ixgbe.c | 173 +++++++++++++++++++++++++++++++++++------------------=
-----
> ------
> =C2=A01 file changed, 95 insertions(+), 78 deletions(-)
>=20

Is Ben still maintaining ethtool? =C2=A0I ask because I have this series wh=
ich I
sent out earlier this month, with no word and I know there is at least one
other ethtool patch series that has had no response or committal from who
ever is maintaining ethtool.

I know we discussed last netconf that we should look at possibly a new tool
to address the shortcomings of ethtool, but I was not aware we had
abandoned maintaining the current ethtool already before any replacement
tool has been developed.
--=-o0AX7mYwP7+oVVmFWRre
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXROf/AAoJEOVv75VaS+3O6MkQAKebikkeSpfjapDe9MeYvlGt
BzYU/SoMzI1cPjVRdtfK7iz1zOBxvtsqQ28/CMFNB1If+7wosJEtWGRWh2WZYgQd
pLuyoYn8u/HmDv/u+l53I+fmmOk9HybyCFTmF9ezwMVrKhf1uv58CrSOqaW0SkM3
JPnwymbRaNyLhzBOVYqWR+E3Odg5SKE/QelQO8faKQUiZO0tDauk2kR7UbOmlVcS
7AWj+fxhALryWaannleBsdJB0Sfk/WoCfBfU/Wp57T+q4CjWW437xO38vpcMNmo9
raHXyPfBSJDxShcYfh5iH55iN47DMegKBdoS3XtQPUAOtd3FLqr9muEMNoWPdz5U
ZsBjIVjHI37ZFt5JGukasoDDu3/HamYTSpze1U+2Mdh8/ggpGGzZ/uT9D84jxAEp
NmQt7uUlS9ET/3C9ATKEqCG97w1AigtneCfSvUPTQxScyBjDLc/0s2eC9YK/WAfH
23ZazpFI84ia01bB9ZzV//qkictida9cIcyVum+JdQu36XpCKSLiGxM2Xy7jsVQK
iTlpHVT7vVGhgpwFlUKFFRcLhqY8AMpdWIDbC9tXjF3l16o1t2vNAWXbLrfnekpr
J1KGDsN9Tijg+/zFz1SnKS/oXgbjnpxus1OufXTzTVxTVr+SLRY6Sx4601OhlefY
6oZhoxsvBZln19duA28u
=Zz0q
-----END PGP SIGNATURE-----

--=-o0AX7mYwP7+oVVmFWRre--
