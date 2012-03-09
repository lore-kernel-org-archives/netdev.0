From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: manual merge of the net-next tree with the powerpc
 tree
Date: Fri, 9 Mar 2012 17:44:16 +1100
Message-ID: <20120309174416.2b936c5a4a116d56f9a25502@canb.auug.org.au>
References: <20120309133646.fb8cc30d8c2fd0ef7784d72c@canb.auug.org.au>
	<20120308.221534.712157352097242982.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__9_Mar_2012_17_44_16_+1100_Xa7Sppg5lHzHMH4A"
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, benh@kernel.crashing.org,
	paulus@samba.org, linuxppc-dev@lists.ozlabs.org, joe@perches.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120308.221534.712157352097242982.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__9_Mar_2012_17_44_16_+1100_Xa7Sppg5lHzHMH4A
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

On Thu, 08 Mar 2012 22:15:34 -0800 (PST) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Fri, 9 Mar 2012 13:36:46 +1100
>=20
> > Today's linux-next merge of the net-next tree got a conflict in
> > drivers/net/ethernet/ibm/iseries_veth.c between commit e92a665949f6
> > ("net: powerpc: remove the legacy iSeries ethernet driver") from the
> > powerpc tree and commit 41de8d4cff21 ("drivers/net: Remove alloc_etherd=
ev
> > error messages") from the net-next tree.
> >=20
> > I just removed the file.
>=20
> If it makes life easier for anyone I can put the driver removal patch
> into net-next.

In this case, I think it will actually help, thanks.  Note that it won;t
apply cleanly to your tree, but the fixup is easy :-)

And I discovered that "git am" doesn't like the style of patch I did
(without the body of the deleted file).  If you just delete
drivers/net/ethernet/ibm/iseries_veth.c before trying to apply the patch
it will probably work.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__9_Mar_2012_17_44_16_+1100_Xa7Sppg5lHzHMH4A
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPWabAAAoJEECxmPOUX5FEzWAP/R3Cn2VaCfSqhKOWLSvnK2If
6oNWyTA79xH9/0qoOqtR6GGcYaWoEhZKeKqI9K3oQB5+c6nA76mqxzVMydVkgJvC
oe0Rn8G7QJg6RJ/lbV8m4F8dmzfCmk1OywLdd25l3miNQvTSda9qCHG9DtsoITA/
uWs7tLCq2TuYNmFcCasLEA7SjyxAsN2c34KCxfZJuj53hy9MIFA0he4f7x79pIkK
p0wJ7bF1mQYFdS3Q04p3IdoINWz2gS7ceioj9cWZxAskhiAXytV41q7ia01VnrNX
VXs5H9kP/hFOI8JiaX8UqLC9mDlqQKVahiJplIVQipJhaZk26JGAf8jHNV6AocdO
XFteSJzHbIuicI2dDXHkI0coh3dk7qTEg8D0O6PRw+tKXHIB5lThJGR0BGQgHQeb
MQsDXVibwnZdFFYDKIkYQl6uyhZ3ARvcbGvQr9frSQhdiEcTmW8YtXOorbhuCmuj
rnxgjAgiFuSCVMgbBPxi5rSoKfgbAvtX93ehN11A5/N4hy41c33ClHsBxgWuuUSl
3kSR+K/XObDDkv2QRHhY3RMlNLwDiAuQMssjZlYTZEzKGuHA6H3wneUx5YBDU9m8
m0kVBswkHocCnJhwKChIrKmSk5/frohEPYYPlDE54TWgnYxbRVuUKIe+PiprM+HW
D6GIajSwb847xtn1kZ9I
=D9p1
-----END PGP SIGNATURE-----

--Signature=_Fri__9_Mar_2012_17_44_16_+1100_Xa7Sppg5lHzHMH4A--
