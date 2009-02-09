From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: accelerated vlan gives pcap tagged packets untagged
Date: Mon, 9 Feb 2009 14:34:05 +0100
Message-ID: <20090209143405.76ac6387@mjolnir.drzeus.cx>
References: <20090208123735.15d9ea4b@mjolnir.drzeus.cx>
	<49902E35.6060506@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=PGP-SHA1; boundary="=_freyr.drzeus.cx-17045-1234186455-0001-2"
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-117-125-11.tcdsl.calypso.net ([82.117.125.11]:33346 "EHLO
	smtp.drzeus.cx" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755223AbZBINeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Feb 2009 08:34:19 -0500
In-Reply-To: <49902E35.6060506@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-17045-1234186455-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 09 Feb 2009 14:23:01 +0100
Patrick McHardy <kaber@trash.net> wrote:

>=20
> Current kernel version (I think starting with 2.6.28) relay the
> VLAN tag information to userspace through packet sockets. The
> current libpcap release from tcpdump.org (or the one Dave keeps
> in a git tree on kernel.org) supports reconstructing the tags.
>=20

Ah. This is a Fedora 10 machine so it's running a 2.6.27 kernel. I'll
see if I can do a test with an updated kernel.

Do you know if dhcpd also uses libpcap so that it will stop seeing
packets it shouldn't?

Rgds
--=20
     -- Pierre Ossman

  Linux kernel, MMC maintainer        http://www.kernel.org
  rdesktop, core developer          http://www.rdesktop.org

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-17045-1234186455-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)

iEUEARECAAYFAkmQMNQACgkQ7b8eESbyJLhHcwCgutMKZtsd0dX+lULo5Ka6U7Fz
GW4AmNfYAFpXTT+kKXaUIoHbydEAyS0=
=r8j8
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-17045-1234186455-0001-2--
