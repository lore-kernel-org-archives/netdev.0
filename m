From: Eric B Munson <emunson@mgebm.net>
Subject: Re: 2.6.39-rc2 boot crash
Date: Wed, 6 Apr 2011 17:20:41 -0400
Message-ID: <20110406212041.GA2596@mgebm.net>
References: <20110406184753.GA7691@mgebm.net>
 <1302115953.8094.217.camel@nimitz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="UugvWAfsgieZRqgk"
Cc: linux-kernel@vger.kernel.org, kaber@trash.net, zbr@ioremap.net,
	davem@davemloft.net, gregkh@suse.de, ksrinivasan@novell.com,
	netdev@vger.kernel.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1302115953.8094.217.camel@nimitz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--UugvWAfsgieZRqgk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, 06 Apr 2011, Dave Hansen wrote:

> On Wed, 2011-04-06 at 14:47 -0400, Eric B Munson wrote:
> > I am seeing a boot crash on my machine with 2.6.39-rc2.  I don't yet ha=
ve
> > netconsole setup and I don't have serial so the best I can do at the mo=
ment
> > is a couple of pictures of the stack trace.
> >=20
> > http://tinypic.com/r/2zsr19i/7
> >=20
> > And=20
> >=20
> > http://tinypic.com/r/2iw22dj/7
> >=20
> > I will try and get a net console working for better output, is there
> > anything else that would help?
>=20
> This:
>=20
> > boot_delay=3D     Milliseconds to delay each printk during boot.
> >                         Values larger than 10 seconds (10000) are chang=
ed to
> >                         no delay (0).
> >                         Format: integer
>=20
> sometimes gives you enough time to get something out of the system.  You
> might also want to try and boot the same kernel in a VM.  It might just
> be a weird configuration issue, or maybe even a lockdep bug.  If it's
> not hardware related, booting in a VM should help a lot.
>=20
> -- Dave
>=20

A bisect points at commit 04f482faf50535229a5a5c8d629cf963899f857c for the
first bad one.  Unfortunately, I have not made netconsole work yet and the
hang is happening mostly right when X starts so I can't even see the consol=
e.
I will keep at the netconsole and see if I can get it functioning, also I w=
ill
try to boot this kernel in a VM and see if that helps.

Eric

--UugvWAfsgieZRqgk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNnNkpAAoJEH65iIruGRnNesUIAMZSAbFc+AyCMSBCUY1vidw/
VV3XIhkhfOMDNulXv+csvCb+7s0RXmVtmywvXYfBqx7ccpHKPGkXr506aKdVGQvq
cRlYShJeAodIqOjxDc2qefoXZPDwXEe2JsA/TZznNKsa6AluMb78sfbPjptRjDim
K6uyric75t4UftpoPbb5MG3gLw+0BiE50ZS9gxhTewQT+j/Fx2nPL+ibdHlssI6x
YakX26kX7bXRfgTyl3T1JiOM2O0GidV/GMKq/G/WEobx5vVLkgNxLkJ/q4CDd1qR
zFgvt4+0tILNDlshLrRDF/o8eLQetubd94EHE5RxyLq6llH2hsXWMrwKb+bqrCQ=
=wQLp
-----END PGP SIGNATURE-----

--UugvWAfsgieZRqgk--
