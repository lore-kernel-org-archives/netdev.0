From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 10:43:41 -0700
Message-ID: <482B24CD.2040209@redhat.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com> <20080514080942.GB4462@gerrit.erg.abdn.ac.uk> <482AF1DB.1060608@redhat.com> <20080514144518.GA30578@gerrit.erg.abdn.ac.uk> <482B0DF8.9060001@redhat.com> <20080514172204.GA1036@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ulrich Drepper <drepper@redhat.com>,
	R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59019 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762600AbYENRoS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 13:44:18 -0400
In-Reply-To: <20080514172204.GA1036@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Gerrit Renker wrote:
> But either is important be considered when a user unambiguously speci=
fies
> ai_socktype and/or ai_protocol; to avoid bad/brittle workarounds.

OK, I added the support.  Will be in glibc 2.9.

But what about $subject?  What is the story with SOCK_DCCP?  I added it
now but if it's going away I'd rather remove it.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKyTN2ijCOnn/RHQRAhyWAJoDEgLDYcL/VUQyz5ykje2r4FWVFwCbBdvq
U1W/yHRv5cAuuWr4927IGUw=3D
=3DrjjM
-----END PGP SIGNATURE-----
