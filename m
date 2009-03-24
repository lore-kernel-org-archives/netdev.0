From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] bnx2: Use request_firmware()
Date: Tue, 24 Mar 2009 04:27:23 +0000
Message-ID: <20090324042723.GJ3051@decadent.org.uk>
References: <1237501747.4126.10.camel@deadeye.i.decadent.org.uk> <1237503884.16140.23.camel@HP1> <20090319232541.GA19262@wavehammer.waldi.eu.org> <20090320.155030.164080684.davem@davemloft.net> <1237844879.18617.20.camel@HP1> <20090323222915.GA29609@wavehammer.waldi.eu.org> <1237850656.18617.34.camel@HP1> <49C825EC.50100@hp.com> <1237857085.18617.47.camel@HP1> <49C836D0.1080304@hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="TybLhxa8M7aNoW+V"
Cc: Michael Chan <mchan@broadcom.com>,
	Bastian Blank <waldi@debian.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:57287 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750721AbZCXE1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 00:27:31 -0400
Content-Disposition: inline
In-Reply-To: <49C836D0.1080304@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--TybLhxa8M7aNoW+V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-03-23 at 18:26 -0700, Rick Jones wrote:
> Michael Chan wrote:
> > On Mon, 2009-03-23 at 17:14 -0700, Rick Jones wrote:
> >=20
> >>Michael Chan wrote:
> >>
> >>>May be I'll break up each firmware section into a
> >>>different file and the file name will be updated with each version.
> >>>This will allow different sections to be updated separately and older
> >>>kernels will still have access to the older firmware.
> >>
> >>Is that really necessary?  It is enough "fun" finding just the one firm=
ware file=20
> >>as it is.
> >=20
> >=20
> > If all the firmware sections are in the same file, much of the firmware
> > file will be duplicated in a new file when we update just one section.
>=20
> So?  Perhaps I'm just experiencing distro pain which may not continue to =
exist or=20
> which may not matter to netdev, but when one is installing to a system th=
at uses=20
> a core NIC which has firmware cast-out into "non-free" siberia, life is "=
fun"=20
> enough making sure one has the one firmware file let alone N of them.
[...]

If you're referring to Debian, that is exactly what Bastian and I are
working on.  Sourceless firmware is considered non-free, but it can
still be packaged, as the bnx2 firmware already has been.  We've also
had some discussions with David Woodhouse about semi-automatically
packaging all of the firmware that's now in the firmware subdirectory
and is clearly licensed.

Ben.


--TybLhxa8M7aNoW+V
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iD8DBQFJyGEr79ZNCRIGYgcRAr9bAJ4kfrYL2FgQPG1ZR2Kkfn9df/deaQCgpv02
lsWBD66l2o8DsYmDwL/BhLo=
=Tqb9
-----END PGP SIGNATURE-----

--TybLhxa8M7aNoW+V--
