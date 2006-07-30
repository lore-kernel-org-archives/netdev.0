From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC 1/4] kevent: core files.
Date: Sun, 30 Jul 2006 01:08:42 -0700
Message-ID: <44CC690A.5030204@redhat.com>
References: <20060709132446.GB29435@2ka.mipt.ru>	 <20060724.231708.01289489.davem@davemloft.net>	 <44C91192.4090303@oracle.com> <20060727200655.GA4586@2ka.mipt.ru>	 <44C930D5.9020704@oracle.com> <20060728052312.GB11210@2ka.mipt.ru>	 <44CA586C.4010205@oracle.com> <20060728184445.GA10797@2ka.mipt.ru>	 <44CA613F.9080806@oracle.com>  <44CAD81A.9060401@redhat.com> <1154147562.2451.30.camel@entropy>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig86D0700284F405347779E45F"
Cc: Zach Brown <zach.brown@oracle.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34945 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751127AbWG3IHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2006 04:07:14 -0400
To: Nicholas Miell <nmiell@comcast.net>
In-Reply-To: <1154147562.2451.30.camel@entropy>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig86D0700284F405347779E45F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Nicholas Miell wrote:
> [...] and was wondering
> if you were familiar with the Solaris port APIs* and,

I wasn't.


> if so, you could
> please comment on how your proposed event channels are different/better=
=2E

There indeed is not much difference.  The differences are in the
details.  The way those ports are specified doesn't allow much room for
further optimizations.  E.g., the userlevel ring buffer isn't possible.
 But mostly it's the same semantics.  The ec_t type in my text is also
better a file descriptor since otherwise it cannot be transported via
Unix stream sockets.

--=20
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro St =
=E2=9E=A7 Mountain View, CA =E2=9D=96


--------------enig86D0700284F405347779E45F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iD4DBQFEzGkP2ijCOnn/RHQRAvC2AJjnzxTdqNtKpVSI4QdSJg30AUFMAJ96RT9c
098L1wtV2qSAWu8UrK0tfA==
=PJXY
-----END PGP SIGNATURE-----

--------------enig86D0700284F405347779E45F--
