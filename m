From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 11:06:16 -0700
Message-ID: <482B2A18.6000708@redhat.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com> <200805142047.40726.rdenis@simphalempin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <dlstevens@us.ibm.com>,
	David Miller <davem@davemloft.net>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <rdenis@simphalempin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54345 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760911AbYENSGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 14:06:42 -0400
In-Reply-To: <200805142047.40726.rdenis@simphalempin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

R=C3=A9mi Denis-Courmont wrote:
> Do you intend to=20
> implement "dccp" when parsing /etc/services, though?

No special support is needed.  This is just a string.  Add */dccp
entries and see it just work.


Just to conclude this: I will add none of DCCP, UDPlite, SCTP to the
default list.  For now.  Maybe SCTP take off at some point and is worth
it.  But not now.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKyoY2ijCOnn/RHQRAsVmAKCPtd+MIVisShBE6exgIh6AJoGWmQCgkaHt
WYuOfl63Q0oS1TdWYmhP95A=3D
=3D2/DS
-----END PGP SIGNATURE-----
