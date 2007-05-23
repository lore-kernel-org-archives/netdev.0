From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: r8169: hard freezes on TX
Date: Wed, 23 May 2007 08:48:25 +0200
Message-ID: <200705230848.33299.eike-kernel@sf-tec.de>
References: <200705201520.36672.eike-kernel@sf-tec.de> <20070522202934.GA21991@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart3494678.9gMTz0j9P8";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:35980 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756373AbXEWGsg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 May 2007 02:48:36 -0400
In-Reply-To: <20070522202934.GA21991@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3494678.9gMTz0j9P8
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

=46rancois Romieu wrote:
> Rolf Eike Beer <eike-kernel@sf-tec.de> :
> [...]

Ok, just tested. I used a file of 200MB and copied it to another host on th=
e=20
LAN. If I used our 100 MBit switch nothing happened. When I put a 10 MBit h=
ub=20
in the middle it died at 77 MB.

> > I often see freezes when I do much outgoing transfer. I have never seen
> > this happening on incoming transfers. When this happens the system locks
> > up hard, I don't see anything in the log. Since this is my laptop I have
> > trouble debugging it: there is no serial console and debugging this via
> > netconsole doesn't look like a good idea.
>
> Keyboard leds are dead afterwards I guess, right ?

Yes.
> > When I say "much outgoing transfer" this means "several megabytes". If I
> > copy out 30 MB I almost everytime get this. I usually copy that much on=
ly
> > at home when I feed my gentoo server. That host only has a 10 MBit
> > connection. Nevertheless I've also seen that on different hosts using
> > different files on different protocols (ftp, scp, smb).
> >
> :o/
>
> So it can be reproduced with a simple ftp put of several megabytes of
> data completely cached in memory (no disk access) ?

I used scp, but: yes.

Eike

--nextPart3494678.9gMTz0j9P8
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGU+PBXKSJPmm5/E4RAnwCAJ9roQx4mOCRZB2VnCCDSXzAZXFQGwCfTDCX
IcijChxMG4EwBbjVTuhkBTM=
=4i6d
-----END PGP SIGNATURE-----

--nextPart3494678.9gMTz0j9P8--
