From: Ulrich Drepper <drepper@redhat.com>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Wed, 14 May 2008 07:06:19 -0700
Message-ID: <482AF1DB.1060608@redhat.com>
References: <20080513093718.GA24185@gerrit.erg.abdn.ac.uk> <20080513162325.GF15306@ghostprotocols.net> <20080513170325.GB11499@gerrit.erg.abdn.ac.uk> <200805132037.39580.rdenis@simphalempin.com> <4829E87F.1070006@redhat.com> <20080514080942.GB4462@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ulrich Drepper <drepper@redhat.com>,
	R?mi Denis-Courmont <rdenis@simphalempin.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	David Stevens <
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36641 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752523AbYENOLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2008 10:11:00 -0400
In-Reply-To: <20080514080942.GB4462@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Gerrit Renker wrote:
> RFC 3493 says that 0 for socktype/protocol means that caller will acc=
ept
> any socket type / protocol, so presumably this does include DCCP and =
UDP-Lite.

I know what the RFC says.  But there are a gazillion of protocols out
there and I won't create a record for all of them in case socktype and
protocol are zero.  That's just overkill in 99.9% of all cases.

I assumption is that UDPlite is just too specialized to be useful to a
wide array of people.  Yes, it case be supported if explicitly requeste=
d
but should be returned if 0/0 is passed in.

What I'm asking is whether this is a fair assumption and what the story
of DCCP is.

- --
=E2=9E=A7 Ulrich Drepper =E2=9E=A7 Red Hat, Inc. =E2=9E=A7 444 Castro S=
t =E2=9E=A7 Mountain View, CA =E2=9D=96
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQFIKvHb2ijCOnn/RHQRAlz5AKCvOSOm7PR7ljfyZ9krq0TtzZUTbgCdFLLj
=461fvWvR+VvXUSE5x+VtgsqQ=3D
=3D3Lft
-----END PGP SIGNATURE-----
