From: Sven Eckelmann <sven@narfation.org>
Subject: Re: pull request: batman-adv 2011-05-01
Date: Tue, 3 May 2011 14:23:42 +0200
Message-ID: <201105031423.45565.sven@narfation.org>
References: <1304284234-27338-1-git-send-email-sven@narfation.org> <20110502.150620.39172573.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart8642732.yOrcoASOBv";
  protocol="application/pgp-signature";
  micalg=pgp-sha512
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:39953 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751419Ab1ECMXt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2011 08:23:49 -0400
In-Reply-To: <20110502.150620.39172573.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart8642732.yOrcoASOBv
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Tuesday 03 May 2011 00:06:20 David Miller wrote:
[...]
> I'll pull this, but I really want you to resolve atomic_dec_not_zero()
> properly.
>=20
> It does not belong in any batman-adv header file.
>=20
> Instead it belongs in all of arch/${ARCH}/include/asm/atomic.h and
> include/asm-generic/atomic.h

I agree.

> Please submit a patch which puts it in the proper place to linux-kernel

Thanks, will do that later - just prepared a patch
 https://lists.open-mesh.org/pipermail/b.a.t.m.a.n/2011-May/004562.html but=
=20
currently have no time to make a final version (maybe in 8 hours) and send =
it=20
to linux-kernel.

Thanks,
	Sven

--nextPart8642732.yOrcoASOBv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAABCgAGBQJNv/PPAAoJEF2HCgfBJntGnQYQAMD3fTqoP6+kch6FPo1yxYYa
3QpkPAcAFUjBL0v/qY2bKrHzLbzrL4Jr/oZ+aTyRhRVyLmnaQOAV8XIB81qJ+SOe
FEDGRx3iT0xb/8Pr2he1Yu8jVZHFwr+JLmhai9brFXQ6fXkz/eGNrnh4u4o5wvAB
cZ2ubAY1whjADG/OeMwWWb5SRc2EhFOgGET/ab6M1tgSR6BoALS/bOuZYq7J7PTl
z0De58CZrxMB2Rg5yPeh3T1aNOlj6TaLsZdIqTDao0AlmiyeoK8pfD8vdXpdnFyL
AclAnLsInxJSkVXu8zSGJTcM3CaL5BczgwnmO/pUZBJ2HiZ11awl6lcM05pWJRDr
LDxrFJE1IKTVvafKBJ37u4Z2aWepEQx8mVMeTCz/56T9A3sTkz76Xi/iJhDPuXPm
B8FG47OtQ2lU1+iLsOD21inEqqP9rhEuOSiOCiDR1WuLnimfBH7HHl95DvWFa/yL
xeKnm+vKOBM2EtD+Pmg7d5KwsidxhHbzYAw3vFza+X8IWPyLz3paL8pkH520d8aH
uHfRl87dbmVBpPWB1SG/1sK6KbcCfREc2dQVgOm3rqebaPuwctYOtHdC7hDWqTRJ
RSDgUOhd2sg1tpBCANExi6mczJyVM/ZEMFjq/D8w+xzfkl9wvvyb7IH3S7fclRpk
HDD74bdIws5UaRyJNXvq
=Y6xt
-----END PGP SIGNATURE-----

--nextPart8642732.yOrcoASOBv--
