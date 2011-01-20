From: Pierre Ossman <pierre-list@ossman.eu>
Subject: Re: [RFC][PATCH] Export all RA options that we don't handle to
 userspace
Date: Thu, 20 Jan 2011 09:15:05 +0100
Message-ID: <20110120091505.165737a1@mjolnir.ossman.eu>
References: <20101212144300.68e0fb16@mjolnir.ossman.eu>
	<20101212144706.1d2be015@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-13745-1295511308-0001-2"
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:56453 "EHLO
	smtp.ossman.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752110Ab1ATIUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 03:20:41 -0500
In-Reply-To: <20101212144706.1d2be015@mjolnir.ossman.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-13745-1295511308-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Ping!

The userspace support is rather useless without these kernel bits...

On Sun, 12 Dec 2010 14:47:06 +0100
Pierre Ossman <pierre-list@ossman.eu> wrote:

> Second patch that exports everything. If noone objects to this model,
> then merge the two patches and just use the commit message from the
> second one.
>=20
> Pros:
> - Kernel doesn't need to be updated for every new RA option that might
>   show up.
>=20
> Cons:
> - Possible security issue if it requires less privilege to read these
>   netlink messages than to open a raw ICMPv6 socket.
> - List of types the kernel is interested in is now in two places in the
>   code, creating a risk for getting out of sync. I tried to come up
>   with a structure that would prevent this, but couldn't think of
>   anything that wouldn't require large changes. Ideas welcome...
>=20
> Rgds


--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by FRA, a
  Swedish intelligence agency. Make sure your server uses
  encryption for SMTP traffic and consider using PGP for
  end-to-end encryption.

--=_freyr.ossman.eu-13745-1295511308-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iF4EAREIAAYFAk037wsACgkQopDLsoqlmEI0CAD+MHfMN4xK0mewoaTaM257AkCO
A2GLWWp5715B6g27uAoA/1gOX8gpuB88iF2fSuxnfOnOcwT3noYwX70ND4pGUiBu
=FrSU
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-13745-1295511308-0001-2--
