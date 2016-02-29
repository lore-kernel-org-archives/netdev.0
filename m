From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next] hv_netvsc: add ethtool support for set and get
 of settings
Date: Mon, 29 Feb 2016 22:34:38 +0000
Message-ID: <1456785278.3098.146.camel@decadent.org.uk>
References: <1456442648-13941-1-git-send-email-sixiao@microsoft.com>
 <20160229.170910.1568620456454101151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============8833426238648205991=="
Cc: devel@linuxdriverproject.org, haiyangz@microsoft.com,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, sixiao@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20160229.170910.1568620456454101151.davem@davemloft.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org


--===============8833426238648205991==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+YjuCSLI6Vm0OIaCpXn7"


--=-+YjuCSLI6Vm0OIaCpXn7
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-02-29 at 17:09 -0500, David Miller wrote:
> From: Simon Xiao <sixiao@microsoft.com>
> Date: Thu, 25 Feb 2016 15:24:08 -0800
>=20
> > This patch allows the user to set and retrieve speed and duplex of the
> > hv_netvsc device via ethtool.
> >=C2=A0
> > Example:
> > $ ethtool eth0
> > Settings for eth0:
> > ...
> >=C2=A0=C2=A0=C2=A0=C2=A0 Speed: Unknown!
> >=C2=A0=C2=A0=C2=A0=C2=A0 Duplex: Unknown! (255)
> > ...
> > $ ethtool -s eth0 speed 1000 duplex full
> > $ ethtool eth0
> > Settings for eth0:
> > ...
> >=C2=A0=C2=A0=C2=A0=C2=A0 Speed: 1000Mb/s
> >=C2=A0=C2=A0=C2=A0=C2=A0 Duplex: Full
> > ...
> >=C2=A0
> > This is based on patches by Roopa Prabhu and Nikolay Aleksandrov.
> >=C2=A0
> > Signed-off-by: Simon Xiao <sixiao@microsoft.com>
>=20
> Applied, thanks.

I missed this due to flu, but now I look at it - I don't see the point.
Link speed isn't meaingful for a memory-based transport, so "unknown"
is correct. =C2=A0The link is effectively full duplex though.

If the issue is that ethtool is a bit shouty about unknowns, let's
consider changing that in ethtool, not teaching drivers to lie.

Ben.

--=20
Ben Hutchings
If God had intended Man to program,
we'd have been born with serial I/O ports.
--=-+YjuCSLI6Vm0OIaCpXn7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVtTHfue/yOyVhhEJAQpkSg/9Fbdl1EGaJ0a8TRc++oD/VpnD8q9P+wwJ
wuZYpVbNF3roiHdSU+KUXCl1FeTl0UEL3yqkWMYWVAh4bvPWFPx7V2nAw9Qb5aXZ
YWlUjXY55NBhHt8aR8xmvT3EYHNV9dgOTa0ba4gYTXIQzB9xJt2NVo8hGWaPAH9K
+MU7dMUR06MYrTFcslaBtQ4NNiRljVxYU9w+2BLDL8c7cWWz6f7rz5Eq1cM2jbsp
LcA4ay65UXG+JaaLhIFVOsrnlyB5Lwlmgp0f2xGhFpebTp0YKD7YtyK6C5Q7RFwZ
B6nMCHB9olpr4fhNkAPBXXBa5oq8JFaJVsOp11u6cekF2BONqR3GCCvfJQq/PEks
WRrS8cfKf58h5ej9429nDVNi27wqCgqRx3o5V7mPfrSp0KlVnb5vbVePH2csdZFk
MsazzFyHO7DSZpChtjMu+VxCzj0Xg8GSYGVLRi5hMG+z3kT9Qk2cWl7veGaoEajv
rIz4wZ5p18oxfe6D84ft0PuIWRvOKjPrMxJjaJAy+4eWiWTDPojgll/GQZiVgA/N
mpeoutULo9JsGODZq/lbhBXCA7AgPFKFFsyCffgsx/vGQrJWUW2HYnbcMH6CE2v/
EQqNgBSUHeEqpyF/HHJPLKj13y6M2IXBUcigT5Ld2yaLllZMIEhr8pexFZMb+oSL
NaYeRNSSA0c=
=v2Pq
-----END PGP SIGNATURE-----

--=-+YjuCSLI6Vm0OIaCpXn7--

--===============8833426238648205991==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
devel mailing list
devel@linuxdriverproject.org
http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel

--===============8833426238648205991==--
