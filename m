From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: r8169: hard freezes on TX
Date: Thu, 7 Jun 2007 16:13:42 +0200
Message-ID: <200706071613.47077.eike-kernel@sf-tec.de>
References: <200705201520.36672.eike-kernel@sf-tec.de> <20070604214603.GA29311@electric-eye.fr.zoreil.com> <200706050933.28046.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8818661.ePeCRsb54i";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sf-mail.de ([62.27.20.61]:51595 "EHLO mail.sf-mail.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765918AbXFGPw2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 11:52:28 -0400
In-Reply-To: <200706050933.28046.eike-kernel@sf-tec.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart8818661.ePeCRsb54i
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Rolf Eike Beer wrote:
> You wrote:
> > Rolf Eike Beer <eike-kernel@sf-tec.de> :
> > [...]
> >
> > > I just had another freeze using your patches. After 512kB over smb it
> > > was dead.
> >
> > In-kernel smb/cifs ?
>
> Copying to a partition mounted via smb:// protocol in konqueror which uses
> kio_smb (userspace io slave).

This start to get weird. I sent a single file (~4 MB) via FTP to a host=20
connected via a 10 MBit Hub: freeze. Now I decided to beat it and tested a=
=20
bit around. I copied some folders of my MP3 collection over there, all went=
=20
fine. Then I created a tar file of ~400 MB and sent that which also went=20
fine. Even the next try with this file didn't produce a crash. What was=20
different on this tests was that I used the console instead of X (don't wan=
t=20
to munch up too many file systems). Any ideas?

Eike

--nextPart8818661.ePeCRsb54i
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBGaBKbXKSJPmm5/E4RAv26AJ47ZUvkQYXqUfAuWRwlRrPnBkWVnQCfaXeR
SkrCncZJSQ9oScN1J2PhQUI=
=larp
-----END PGP SIGNATURE-----

--nextPart8818661.ePeCRsb54i--
