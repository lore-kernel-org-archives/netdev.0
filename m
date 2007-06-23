From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [RFD] First draft of RDNSS-in-RA support for IPv6 DNS autoconfiguration
Date: Sat, 23 Jun 2007 19:51:55 +0300
Message-ID: <200706231952.03096@auguste.remlab.net>
References: <OFD5BE4667.E4A6D7D5-ON88257303.005932BE-88257303.005C40E3@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8103190.h7vDjdSAcF";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "C. Scott Ananian" <cscott@laptop.org>, cananian@gmail.com,
	netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poy.chewa.net ([194.242.114.73]:3170 "EHLO poy.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759719AbXFWQwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jun 2007 12:52:08 -0400
In-Reply-To: <OFD5BE4667.E4A6D7D5-ON88257303.005932BE-88257303.005C40E3@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart8103190.h7vDjdSAcF
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Le samedi 23 juin 2007, David Stevens a =E9crit :
>         No, in fact! I didn't hear anyone suggesting that all of
> neighbor discovery be pushed out of the kernel. All I suggested is
> that you read a raw ICMPv6 socket for RA's that have the RDNS header
> and the app _process_the_RDNS_header. The kernel should still
> continue to do everything it needs to with the kernel data in the RA.
> Then you just need a hash table (or maybe just a list -- there
> shouldn't be a lot of them) and a timer to delete them when the RDNS
> expiration hits. Easy, right?

The exact thing I pointed out does not work. I *DID* write RA parsing in=20
userland in the past.

>         You might have to change the icmp6_filter, if RA's are not
> already copied to raw sockets (I don't know either way offhand),
> but that's a trivial kernel patch; otherwise, I don't believe you
> have to do anything but read the socket and process the RDNS header
> on RAs you receive.

To reiterate:

How do I authenticate SeND RA? How do I deal with the link going down=20
before the expiration? How do I know "this" interface is doing autoconf=20
at all?

=2D-=20
R=E9mi Denis-Courmont
http://www.remlab.net/

--nextPart8103190.h7vDjdSAcF
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iEYEABECAAYFAkZ9T7MACgkQw+xtvt1tEr3VEACfRgmcAwG1q+wEU+Mcva0VHw1D
tMIAn0d64acHTANFSxHBpJldDPuhiWpf
=73yO
-----END PGP SIGNATURE-----

--nextPart8103190.h7vDjdSAcF--
