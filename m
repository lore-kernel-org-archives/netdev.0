From: Dominick Grift <dac.override@gmail.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Tue, 5 May 2015 10:33:54 +0200
Message-ID: <20150505083354.GA14880@x131e>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
 <20150504133943.GA17043@x131e>
 <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="LQksG6bCIzRHxTLp"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:34973 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756785AbbEEId5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 04:33:57 -0400
Received: by wgyo15 with SMTP id o15so174505762wgy.2
        for <netdev@vger.kernel.org>; Tue, 05 May 2015 01:33:56 -0700 (PDT)
Received: from x131e (217-19-24-195.dsl.cambrium.nl. [217.19.24.195])
        by mx.google.com with ESMTPSA id gj7sm14970342wib.4.2015.05.05.01.33.56
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 01:33:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--LQksG6bCIzRHxTLp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, May 04, 2015 at 11:45:41AM -0700, Cong Wang wrote:

<snip>

> Should be the same issue. Please give the attached patch a try,
> it is compile-tested only.
>=20
> Thanks!

<snip>

Thank you.

I have just booted with the above path and the "oops" is gone

So although the patch may not be optimal, it does seem to take care of the =
issue.

--LQksG6bCIzRHxTLp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQGcBAEBCgAGBQJVSIBtAAoJENAR6kfG5xmcK7EL/jXploJbpfHJ+zC3urMm+czt
9YlofmEpEpy+2Zk14+3BiihGdM3vq3Q8O1qUnSW2tD6vk+PMLlEQHvVi95iKwM+7
F+5VaA+NHMzujVPVt2nZIHDqfWDOaRigPz7qRiBraFlMhwdR2HuKCSEE3VBaxVSZ
0+dOKP/MNYTqe8JsgxIsiZVzcsts9pATrQ/Mu70zbigNZDd//IGdMcml2LPNu7Xf
0mkJ90jqFW9GdOUjNOu/PpKnhWbiCwefTiwyFtX1RYmGBQbeaOwR/GwAk8K2uI0m
p1ETW8mVoMr5ppiZnuJvjtbjK75Wksis05kKc1U4j/bhhMnLnXq9Ydf9+idaIbXr
on2hLDsoShy7OJRs+I3Za5TAms4AOV6pKehutS0ti3mF303RJpYB17qbgZxLShZy
As33ohj4D95KWgSvxtXn41u0avqPdQpkqq+V2vwKcbsM+JBLgfsOvYabdGKBXbC1
uPRyq21LIqLmZhNvW6UTNBwiOrlN7GXzvIjE99Cmkg==
=v8Yi
-----END PGP SIGNATURE-----

--LQksG6bCIzRHxTLp--
