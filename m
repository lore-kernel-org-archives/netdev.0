From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 7/32] rt2x00: make vals static
Date: Fri, 28 Apr 2006 15:40:11 +0200
Message-ID: <200604281540.11656.IvDoorn@gmail.com>
References: <200604280002.58147.IvDoorn@gmail.com> <200604281326.43769.netdev@axxeo.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7353506.CG6T7NOd4k";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nproxy.gmail.com ([64.233.182.185]:27168 "EHLO nproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1030397AbWD1NjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 09:39:06 -0400
Received: by nproxy.gmail.com with SMTP id n29so1580867nfc
        for <netdev@vger.kernel.org>; Fri, 28 Apr 2006 06:39:05 -0700 (PDT)
To: Ingo Oeser <netdev@axxeo.de>
In-Reply-To: <200604281326.43769.netdev@axxeo.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart7353506.CG6T7NOd4k
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Friday 28 April 2006 13:26, Ingo Oeser wrote:
> Sie schrieben:
> > From: Ivo van Doorn <IvDoorn@gmail.com>
> >=20
> > The vals[] arrays in *_init_hw_channels can be made
> > static to optimize memory and reduce stack size.
>=20
> What about static const? They are also constants, right?
> But please try first, if this helps in terms of code size.

Good idea, I'll create a patch to make them constant as well.

--nextPart7353506.CG6T7NOd4k
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBEUhs7aqndE37Em0gRAupIAKDJNznSgsPOb9gSiXWPGmEBojjVEACeKXFC
+FNvOaKJrXvUrf2rPO5Wncg=
=hPQl
-----END PGP SIGNATURE-----

--nextPart7353506.CG6T7NOd4k--
