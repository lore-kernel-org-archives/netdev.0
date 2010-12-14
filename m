From: Pierre Ossman <pierre-list@ossman.eu>
Subject: Re: [RFC][PATCH] Export DNSSL RA option to userspace
Date: Tue, 14 Dec 2010 14:43:19 +0100
Message-ID: <20101214144319.02eced29@mjolnir.ossman.eu>
References: <20101212144300.68e0fb16@mjolnir.ossman.eu>
	<1292332218.15586.49.camel@i7.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-18053-1292334206-0001-2"
Cc: David Woodhouse <dwmw2@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:48301 "EHLO
	smtp.ossman.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014Ab0LNNna (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Dec 2010 08:43:30 -0500
In-Reply-To: <1292332218.15586.49.camel@i7.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-18053-1292334206-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 14 Dec 2010 13:10:15 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Sun, 2010-12-12 at 14:43 +0100, Pierre Ossman wrote:
> > RFC 6106 specifies a new RA option for DNS resolver configuration that
> > therefore needs to end up in userspace.
> >=20
> > This first patch just exports the new option, but I started thinking
> > that this seems overly complex that the kernel needs to be updated
> > every time there is something new of interest to userspace in the RA.
> > So I also have a second patch that exports everything that the kernel
> > doesn't want.
> >=20
> > Patches only compile tested so far as I'm still hacking away at
> > userspace. Comments very much welcome though.
>=20
> Totally untested userspace support:
> http://git.infradead.org/users/dwmw2/connman.git
>=20

Tested userspace support in the form of NetworkManager: ;)

https://bugzilla.gnome.org/show_bug.cgi?id=3D637077

And a radvd to send things out:

http://lists.litech.org/pipermail/radvd-devel-l/2010-December/000507.html

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by FRA, a
  Swedish intelligence agency. Make sure your server uses
  encryption for SMTP traffic and consider using PGP for
  end-to-end encryption.

--=_freyr.ossman.eu-18053-1292334206-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iF4EAREIAAYFAk0HdHsACgkQopDLsoqlmELQYgEAqgFLfcwePHlS0YZetNrPRZPq
TwPsP/n4rzVLWyNRQcQA/jxmdjK12QoVEP8qoqULwQkWx0NVsBIwUwnW+utRxt9G
=n6GG
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-18053-1292334206-0001-2--
