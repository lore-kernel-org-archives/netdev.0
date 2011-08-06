From: Pierre Ossman <pierre-list@ossman.eu>
Subject: Re: accelerated vlan gives pcap tagged packets untagged
Date: Sat, 6 Aug 2011 18:00:46 +0200
Message-ID: <20110806180046.32a57a97@mjolnir.ossman.eu>
References: <20090208123735.15d9ea4b@mjolnir.drzeus.cx>
	<49902E35.6060506@trash.net>
	<alpine.DEB.2.00.0907231656000.12037@callisto.malc.org.uk>
	<4A689159.2010807@trash.net>
	<alpine.DEB.2.00.0907241743180.12037@callisto.malc.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-2517-1312646449-0001-2"
Cc: Patrick McHardy <kaber@trash.net>,
	Pierre Ossman <drzeus-list@drzeus.cx>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Malcolm Scott <linux-netdev@malc.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from c-62-220-186-130.cust.bredband2.com ([62.220.186.130]:36019
	"EHLO smtp.ossman.eu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640Ab1HFQGD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Aug 2011 12:06:03 -0400
In-Reply-To: <alpine.DEB.2.00.0907241743180.12037@callisto.malc.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-2517-1312646449-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Reviving a really old thread.

On Fri, 24 Jul 2009 17:50:26 +0100 (BST)
Malcolm Scott <linux-netdev@malc.org.uk> wrote:

> At 18:35 yesterday, Patrick McHardy wrote:
>=20
> > Malcolm Scott wrote:
> >
> >> In my case, this is manifesting as the DHCP misbehaviour which Pierre
> >> mentioned.  (ISC dhcp3d does not use libpcap, and does not query the
> >> packet socket for the VLAN tag, so it treats every VLAN's packets as f=
or
> >> the default VLAN.)
> >
> > It needs to get the VLAN tag from the auxilliary data.
>=20
> Right.  But backwards compatibility with older apps is the issue.  An app=
=20
> which doesn't go looking for a VLAN tag in the auxiliary data -- because =
it=20
> didn't have to do so prior to 2.6.28 -- will start seeing packets from al=
l=20
> VLANs rather than just the untagged ones.
>=20
> Perhaps what's actually needed is another interface which sees _just_ the=
=20
> untagged packets, e.g. eth0.0 (0 being a reserved VLAN ID meaning 'no VLA=
N',=20
> i.e. equivalent to no 802.1q tag).
>=20

Has any progress been made on this front? I'm running kernel 2.6.32 and
dhcpd 4.1.1 and that combination is still getting very upset by these
stray packages.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by FRA, a
  Swedish intelligence agency. Make sure your server uses
  encryption for SMTP traffic and consider using PGP for
  end-to-end encryption.

--=_freyr.ossman.eu-2517-1312646449-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.16 (GNU/Linux)

iF4EAREIAAYFAk49ZTAACgkQopDLsoqlmEIYFwEAla88+wxsRzOmK1CnSjvkDtDa
/1RR3HG/lwFjqc3hJyoA/2H1Iq3QwBvM2tBziES4mSne81EoNZK35vWxDwGQeOnU
=4hzk
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-2517-1312646449-0001-2--
