From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] make wext wireless bits optional and deprecate them
Date: Wed, 21 May 2008 23:37:44 +0200
Message-ID: <1211405864.3698.7.camel@johannes.berg>
References: <1211026337.3827.25.camel@johannes.berg>
	 <CD993362-B1DE-4E4D-8A5B-E9E2AD7DA04C@holtmann.org>
	 <1211303731.6252.105.camel@johannes.berg>
	 <20080521210352.GA11827@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GgAVnm/Q+ru1odfsGrha"
Cc: Marcel Holtmann <marcel@holtmann.org>,
	netdev <netdev@vger.kernel.org>, Jean Tourrilhes <jt@hpl.hp.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33688 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151AbYEUVn6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 17:43:58 -0400
In-Reply-To: <20080521210352.GA11827@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-GgAVnm/Q+ru1odfsGrha
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > I have filed a patch to fix HAL to use the canonical SIOCGIWNAME at
> > https://bugs.freedesktop.org/show_bug.cgi?id=3D16037. Any further
> > objections to this patch?
>=20
> I think this is going to fall under the "userland ABI" category.
> We can make it a configurable option, but I don't think we are free
> to remove it completely since there is at least existing versions of
> HAL that use it.

Well, yes, I gave it a year in the feature removal schedule since I
thought nobody was actually using it. But if you look at how hal/sysfs
are always dependent on new versions of each other *anyway*, I think we
can get away with removing this in maybe two years time, and
distributors can unset the option if they know their hal is new enough?

johannes

--=-GgAVnm/Q+ru1odfsGrha
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASDSWJ6Vg1VMiehFYAQL2xA//dOA4+OvOlayV5I1wpYkP2bp5Oy6YlLHy
a5VGdyqJXxa0dURRNLeX5XXojoUfIrAh1OaS5kh0lVdAVsABOKXIUChloYyzR0id
zlrG2TJ/f4gw7Zm/mnMDxiWCT2QrP1mCLzHbBsmFHSH61IYJ+pErLsSLYEOViLqF
jRVmw4ZY2ED5LaHHi6s6R6pDvE6Mk7NSCwQufcOvK7auS+OzyqxgdzR5JmtbAKK5
02DbVHV3sxbdMzK81gXsY+l1fYAQVqiqdwMBuaxrrZ4cbeJLQDrt/XihZsr6g+kq
GpTnitLxYbrLXyPAdkeSvzYnmk6MLk8i9gddMvaIuqhFI44lFSY4ysq5VtHnMCJa
3nnsSjYlA8tzY6YrPFeDzT6HE6gS1S7u98eDPgmXP1i3vis8ixfK78j2coRz7UID
/qeIgldOCxkY3q3lY2/DowXFjiDVkQD9r1HWsx9WzN1pD5zdozMyEZNmCP/ayMg4
+zXgxXGzEUwj1JmSmfvbNhpCndSEsyQVnxKIL59NA7gncMgK+QADpUn+wOE/v0+9
U2FlA5BN1mUvoSGSCZObvm4uUDihH1Z2MM0tlDBotwSf9wRXXcZU+7D0S/o7mVYk
dDg4ufldmY5clIbKJ23id02Mfx1IAGI5xVa1nFKXoG4OBVtgJ0mOj005KELs3cdB
C+57s5Bv/ik=
=ntSr
-----END PGP SIGNATURE-----

--=-GgAVnm/Q+ru1odfsGrha--

