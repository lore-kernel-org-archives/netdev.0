From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH iputils v2] ping6: allow disabling of openssl/libgcrypt
 support
Date: Thu, 2 Jun 2016 09:38:29 -0400
Message-ID: <20160602133829.GO7717@vapier.lan>
References: <1464752905-10347-3-git-send-email-vapier@gentoo.org>
 <1464843561-31856-1-git-send-email-vapier@gentoo.org>
 <574FF30E.5000805@miraclelinux.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="Jbyekxk18hnEXT0m"
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:39440 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932619AbcFBNib (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jun 2016 09:38:31 -0400
Content-Disposition: inline
In-Reply-To: <574FF30E.5000805@miraclelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Jbyekxk18hnEXT0m
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On 02 Jun 2016 17:49, YOSHIFUJI Hideaki wrote:
> Mike Frysinger wrote:
> > @@ -891,6 +899,7 @@ int main(int argc, char *argv[])
> >  	}
> >  #endif
> > =20
> > +#ifdef USE_CRYPTO
> >  	if (niquery_is_enabled()) {
> >  		niquery_init_nonce();
> > =20
>=20
> Make niquery_is_enabled() returns 0 without ENABLE_NIQUERY
> and reduce #ifdefs.

i did that originally, but it only reduces like one set.  you have to
define other stubs like niquery_init_nonce too otherwise gcc will throw
warnings & errors.
-mike

--Jbyekxk18hnEXT0m
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXUDbVAAoJEEFjO5/oN/WB9zkQAIdOq97mKGhlmgktL0IBC6u9
1v6d/A7AtTSz6imS3dkcBC0YcDh9kpe68OC8HXEdUsbKAQ/RvjH3caF3j8TnNKXQ
FA9tJg8gbXqrOdVuQ7L/NKez36u4Zhcdd3U15dtyqnCAbincVZcNGXGNMSPqBOiM
ViU5Mhuf8owE+0YnSYbIOZntBFf2WjyWodww94CfIel8cGcxNEGcYFnple/bakkC
BnhNE+VH50jPhPfLpfSJPRJRAW05XrPwJdfXTnTmGagDUOYQpS4db0lbfEx8d3Hq
hhp5Ua3pY1RiWLmt3B6+b7pLj24dOJ6PuvqvBTCZPZr6lwvaafrLf6X8rldWCB9q
JsTfkOT7/1mVYvpFQVjS3IBM49IKTxY6wQHj4PXKyKVR3nZbwZWlbu/2Vz852saY
iPh3MbIUP26regfXBo7XsKlQT2LN6pJ8LdMVWc9fnplokrL3AYa9eZ3zoMN3yVyE
rXuDXmw0ayehKBOpmJZoTyTe0UICq7/EqInqL3eLLM5vOdRFOIivNtsRDnK5klqT
aVsJmgOoHRXK7iGCwknyiWm9/5jRFwQw5MdCLCeeWDQAi8FvvHTSUOskJDUjSoV4
DDhOBwwZFRL1SH0jMOuWeqgY6+yafF07dO0kB59bwZe2xa1uHfgPvi50m+z2Qhxp
vtHosHpz5a98lY7gdAOP
=k1QC
-----END PGP SIGNATURE-----

--Jbyekxk18hnEXT0m--
