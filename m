From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 18/38] Annotate hardware config module parameters in
 drivers/net/can/
Date: Fri, 14 Apr 2017 15:08:13 +0200
Message-ID: <8f7e225b-15fb-58c8-9e3f-34cfafb330d6@pengutronix.de>
References: <149141141298.29162.5612793122429261720.stgit@warthog.procyon.org.uk>
 <149141157162.29162.10145088436840145584.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="olBsFKamhQTkREcfvHemkOaQRclQPh2ox"
Cc: gnomes@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
        linux-can@vger.kernel.org, linux-security-module@vger.kernel.org,
        keyrings@vger.kernel.org, gregkh@linuxfoundation.org,
        Wolfgang Grandegger <wg@grandegger.com>
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <149141157162.29162.10145088436840145584.stgit@warthog.procyon.org.uk>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--olBsFKamhQTkREcfvHemkOaQRclQPh2ox
Content-Type: multipart/mixed; boundary="Qha9AQibvj5dtJ9SqfSMIFgaWPs2egNeq";
 protected-headers="v1"
From: Marc Kleine-Budde <mkl@pengutronix.de>
To: David Howells <dhowells@redhat.com>, linux-kernel@vger.kernel.org
Cc: gnomes@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
 linux-can@vger.kernel.org, linux-security-module@vger.kernel.org,
 keyrings@vger.kernel.org, gregkh@linuxfoundation.org,
 Wolfgang Grandegger <wg@grandegger.com>
Message-ID: <8f7e225b-15fb-58c8-9e3f-34cfafb330d6@pengutronix.de>
Subject: Re: [PATCH 18/38] Annotate hardware config module parameters in
 drivers/net/can/
References: <149141141298.29162.5612793122429261720.stgit@warthog.procyon.org.uk>
 <149141157162.29162.10145088436840145584.stgit@warthog.procyon.org.uk>
In-Reply-To: <149141157162.29162.10145088436840145584.stgit@warthog.procyon.org.uk>

--Qha9AQibvj5dtJ9SqfSMIFgaWPs2egNeq
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 04/05/2017 06:59 PM, David Howells wrote:
> When the kernel is running in secure boot mode, we lock down the kernel=
 to
> prevent userspace from modifying the running kernel image.  Whilst this=

> includes prohibiting access to things like /dev/mem, it must also preve=
nt
> access by means of configuring driver modules in such a way as to cause=
 a
> device to access or modify the kernel image.
>=20
> To this end, annotate module_param* statements that refer to hardware
> configuration and indicate for future reference what type of parameter =
they
> specify.  The parameter parser in the core sees this information and ca=
n
> skip such parameters with an error message if the kernel is locked down=
=2E
> The module initialisation then runs as normal, but just sees whatever t=
he
> default values for those parameters is.
>=20
> Note that we do still need to do the module initialisation because some=

> drivers have viable defaults set in case parameters aren't specified an=
d
> some drivers support automatic configuration (e.g. PNP or PCI) in addit=
ion
> to manually coded parameters.
>=20
> This patch annotates drivers in drivers/net/can/.
>=20
> Suggested-by: Alan Cox <gnomes@lxorguk.ukuu.org.uk>
> Signed-off-by: David Howells <dhowells@redhat.com>
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>
> cc: Wolfgang Grandegger <wg@grandegger.com>
> cc: linux-can@vger.kernel.org
> cc: netdev@vger.kernel.org

Who whill take this patch? Or will it be allied as part of the series by
some of my upstreams?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--Qha9AQibvj5dtJ9SqfSMIFgaWPs2egNeq--

--olBsFKamhQTkREcfvHemkOaQRclQPh2ox
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCgAdFiEE4bay/IylYqM/npjQHv7KIOw4HPYFAljwyb4ACgkQHv7KIOw4
HPYMGAf/YtnBEkHSaSbXxSFzV80ka1beSa0k5UYuBBqoQ/ezinWO1ktSghNXEtf3
PairBJxKIhs873E4+oFl75A1vkIMmSfMTg+J2aLzO2A5PByeVz9eQybhguRXFftn
aapItLAKCe15B+4nNWONTbEvkCZGQFss5cLn03xJDtetoWAZ3+HAumtpYGfMrFkX
26enYopfkzjX6A3EToaNqNdtIPCM9sMT275qrdcTB5377lI2uJrrhOTyKmmGkQaF
g2/YZBRrMStm1USAQkkrnuCHxiZANFu5GMqeBMVCZtV92BZY5pQnkfqnpDMNZVci
TJtqtRfjlTYyVWD0WBqDmf/N84YWUw==
=ij7U
-----END PGP SIGNATURE-----

--olBsFKamhQTkREcfvHemkOaQRclQPh2ox--
