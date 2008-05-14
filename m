From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 10:39:40 -0700
Message-ID: <1210786780.31221.8.camel@w-sridhar2.beaverton.ibm.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk>
	 <20080513162325.GF15306@ghostprotocols.net>
	 <20080513170325.GB11499@gerrit.erg.abdn.ac.uk>
	 <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com>
	 <20080514080942.GB4462@gerrit.erg.abdn.ac.uk> <482AF1DB.1060608@redhat.com>
	 <20080514144518.GA30578@gerrit.erg.abdn.ac.uk>
	 <482B0DF8.9060001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Ulrich Drepper <drepper@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:34855 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751684AbYENRjp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 13:39:45 -0400
In-Reply-To: <482B0DF8.9060001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-05-14 at 09:06 -0700, Ulrich Drepper wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Gerrit Renker wrote:
> > ... but it would still be good to have.=20
> > [...]
>=20
> Thanks, but I think I got this already from previous mails.

SCTP is another protocol that needs to be supported in getaddrinfo().
The minimum support that is good to have is to handle the following
values of ai_socktype and ai_protocol.
  SOCK_STREAM, IPPROTO_SCTP
  SOCK_SEQPACKET, IPPROTO_SCTP

Thanks
Sridhar
>=20
> The question is: is either DCCP or UDPlite important enough to be
> returned in the default list when socktype and protocol are zero?
>=20
> - --
> =E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro=
 St =E2=9E=A7 Mountain View, CA =E2=9D=96
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.4.7 (GNU/Linux)
>=20
> iD8DBQFIKw342ijCOnn/RHQRAmnrAKCO0sevJbyZXNoFG12jSg1NjPC+5wCfUlyH
> cLqvVRQ1gmTkkwl5JnqA9go=3D
> =3DQRU/
> -----END PGP SIGNATURE-----
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

