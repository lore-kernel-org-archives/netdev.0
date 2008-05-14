From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 20:49:18 +0300
Message-ID: <200805142049.19466.rdenis@simphalempin.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <482B0DF8.9060001@redhat.com> <1210786780.31221.8.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ulrich Drepper <drepper@redhat.com>,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:39446 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755369AbYENRtV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2008 13:49:21 -0400
In-Reply-To: <1210786780.31221.8.camel@w-sridhar2.beaverton.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le Wednesday 14 May 2008 20:39:40 Sridhar Samudrala, vous avez =C3=A9cr=
it=C2=A0:
> On Wed, 2008-05-14 at 09:06 -0700, Ulrich Drepper wrote:
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> >
> > Gerrit Renker wrote:
> > > ... but it would still be good to have.
> > > [...]
> >
> > Thanks, but I think I got this already from previous mails.
>
> SCTP is another protocol that needs to be supported in getaddrinfo().
> The minimum support that is good to have is to handle the following
> values of ai_socktype and ai_protocol.
>   SOCK_STREAM, IPPROTO_SCTP
>   SOCK_SEQPACKET, IPPROTO_SCTP

Yeah but I don't think ai_socktype =3D=3D SOCK_STREAM and ai_protocol =3D=
=3D 0 should=20
return IPPROTO_SCTP. Me fears this will break to many TCP applications =
in the=20
field.

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net/
