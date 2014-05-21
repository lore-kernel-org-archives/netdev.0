From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [PATCH net-next] net: cdc_ncm: fix 64bit division build error
Date: Wed, 21 May 2014 12:07:33 +1000
Message-ID: <20140521120733.4cb45333@canb.auug.org.au>
References: <1400484069-13702-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/XzzerdHBPhxTOfEGOWqoIo3"; protocol="application/pgp-signature"
Cc: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
To: =?UTF-8?B?QmrDuHJu?= Mork <bjorn@mork.no>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([103.22.144.67]:57664 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751650AbaEUCHm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 May 2014 22:07:42 -0400
In-Reply-To: <1400484069-13702-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/XzzerdHBPhxTOfEGOWqoIo3
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi all,

On Mon, 19 May 2014 09:21:09 +0200 Bj=C3=B8rn Mork <bjorn@mork.no> wrote:
>
> The upper timer_interval limit is arbitrary and much higher
> than anything usable in the real world.  Reducing it from 15s
> to ~4s to make the timer_interval fit in an u32 does not make
> much difference.  The limit is still outside the practical
> bounds.
>=20
> This eliminates the need for a 64bit timer_interval, fixing a
> build error related to 64bit division:
>=20
>  drivers/built-in.o: In function `cdc_ncm_get_coalesce':
>  ak8975.c:(.text+0x1ac994): undefined reference to `__aeabi_uldivmod'
>=20
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>

I have applied this as a fix patch to linux-next today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/XzzerdHBPhxTOfEGOWqoIo3
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTfAppAAoJEMDTa8Ir7ZwVMjIP/135dHp7fBx4RV8RuDkJQrwE
lxMZk6/fD8AIKA/RO23zYir0kwITr52OxDaI5VvJHQ0sP9jeWW0gJL0wUhJmHEYQ
lq5NqDTRV4lQwVSsRUinWWMjc6URCbbYIjLyfXWRYHUySDXUTrIQh7Yvyt9TQPsO
QqbbW1dSHhr7oT+OtmwI87D5A4FjDJNH4PbRugeLl978n2lQ6poVhHms4plPU0Y7
OrM1kye3Y+U8+FrxwJHQV0EMXZCYwm4+1B2iygfcU84dna1EIkNYHEWYvAMQSATj
tuJE3lTTDCCI4JhoDHY3kys90wP4YQyRiIOehgYcqln66bZ+Uj8d8CboPXp5LQ+c
85KltjcekjrBDfFvDC5DoUpcitg1bCyv/KztYYOpmv+o2EjJ4UliSuMWksB/KECg
f2lQDYJXbSw62R5cAbX1tvYUjEqzmTQMUczqLsfe2/tPQIYQc3fByrwEumDJxjHG
TSnpShww065PEoCLISfqQ1X4Y3ZQA8Sc760gWDiPWtFLVplg+HfCeNTMd5WFK46q
h01p/Tv3j0G+15B1UpkRMvQmdri9vbfLuwckZ7DfGWGFfS2FL3iafsrCtbr5jijL
rloHyjJMqwsBkyxUhDeZFkiTZzOgX+G8OPRSd0CGw9ob68AVDHO86uQdDD63haIG
7ijHsOza8cm390d047JF
=ESW9
-----END PGP SIGNATURE-----

--Sig_/XzzerdHBPhxTOfEGOWqoIo3--
