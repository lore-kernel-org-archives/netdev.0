From: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Subject: PF_PACKET + bind() to proto + outbound packets
Date: Fri, 14 May 2010 02:14:35 +0100
Message-ID: <20100514011435.GL18613@cel.leo>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="bPg9NdpM9EETxvqt"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cel.leonerd.org.uk ([81.187.167.226]:42768 "EHLO cel.leo"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753251Ab0ENBOh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 21:14:37 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--bPg9NdpM9EETxvqt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I'm writing a small traffic watching program, to capture IPv4 packets.

If I have a PF_PACKET socket bound to no particular protocol it sees
both inbound and outbound packets; I can then apply a BPF filter for
just one protocol (i.e. IPv4).

But if instead I bind the socket to the IPv4 protocol specifically, it
no longer sees any outbound packets created by the machine, only inbound
ones.

Is there perhaps some ioctl or sockopt I could enable, to see these
outbound packets too?

Further, would there actually be much difference in practice, in terms
of performance, abilities, etc... even if this were an option turned on?
What's the preferred method of snooping on all of the machine's, for
example, IPv4 traffic?

--=20
Paul "LeoNerd" Evans

leonerd@leonerd.org.uk
ICQ# 4135350       |  Registered Linux# 179460
http://www.leonerd.org.uk/

--bPg9NdpM9EETxvqt
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iD8DBQFL7KP7vLS2TC8cBo0RAiyoAJ49uwYaP1JFaofFYEC7ojtHEl8qGACeL9vz
wmHWHDIWD2PBeDS1xaKdVMk=
=Sh+m
-----END PGP SIGNATURE-----

--bPg9NdpM9EETxvqt--
