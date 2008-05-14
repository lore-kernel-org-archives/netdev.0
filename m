From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 11:07:11 -0700
Message-ID: <482B2A4F.7030908@redhat.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <482B0DF8.9060001@redhat.com> <1210786780.31221.8.camel@w-sridhar2.beaverton.ibm.com> <200805142049.19466.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47569 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752088AbYENSId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 14:08:33 -0400
In-Reply-To: <200805142049.19466.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

R=C3=A9mi Denis-Courmont wrote:
> Yeah but I don't think ai_socktype =3D=3D SOCK_STREAM and ai_protocol=
 =3D=3D 0 should=20
> return IPPROTO_SCTP. Me fears this will break to many TCP application=
s in the=20
> field.

That's not happening.  For SOCK_STREAM TCP is returned.

On the other hand, in the moment, for SOCK_SEQPACKET I return SCTP.  If
this is not the preferred solution let me know now.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKypP2ijCOnn/RHQRAvxYAJ9EqfwRsQq+SuRmkbtdmVs8aDiyGACeMoqx
KqOzlMnpDpzMz+ccEB6oxBA=3D
=3DDHB9
-----END PGP SIGNATURE-----
