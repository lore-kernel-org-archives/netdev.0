From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net] bna: Replace large udelay() with mdelay()
Date: Mon, 10 Mar 2014 20:07:27 +0000
Message-ID: <1394482047.23624.13.camel@deadeye.wl.decadent.org.uk>
References: <1394337802.2861.71.camel@deadeye.wl.decadent.org.uk>
	 <20140310.155723.1592181647227868708.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-SF5qZ+C8qTk8UFVjYyI5"
Cc: vagrant@debian.org, rmody@brocade.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:54771 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753871AbaCJUHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Mar 2014 16:07:42 -0400
In-Reply-To: <20140310.155723.1592181647227868708.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-SF5qZ+C8qTk8UFVjYyI5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-10 at 15:57 -0400, David Miller wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Sun, 09 Mar 2014 04:03:22 +0000
>=20
> > udelay() does not work on some architectures for values above
> > 2000, in particular on ARM:
> >=20
> > ERROR: "__bad_udelay" [drivers/net/ethernet/brocade/bna/bna.ko] undefin=
ed!
> >=20
> > Reported-by: Vagrant Cascadian <vagrant@debian.org>
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>=20
> Applied, thanks Ben.
>=20
> Do you want me to queue this up for -stable?

No, this is a regression in 3.14.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-SF5qZ+C8qTk8UFVjYyI5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUx4bf+e/yOyVhhEJAQrCvg/+JLGGEijHesrgt98HANoD3zGC5y0Os9hx
0phaOyfNM9e0UzqiMluxwysrxPCCc4rc1yYWQDNfLphKjAslMnxR9ReiGT7skJsr
4sngx4DDkkiXB8Opn0/UNTizd5DvAB/0g7vURCvJlceS/+2Rez9T1nh0BYqS9qvb
jSUbs/zMRfp0b65Af7FnD5uPdC1mLGRyAni0BW3Dgwj7rJtzDzK4zFppJE7jSvwb
oCGLe37eft5zgOOO8eYtx0rkL8s6EyVQjMcIifayauGmJueJK2UXarlhId+Knpm7
YO83zRzG8e97Wy+042MhoamYGdT3iZhkGk8kM5A6BhsWIFcZcgoJH7NoFqaHr/dL
lUDkZ0MxuQs+ygDGQZg3tS2QaExchQ30bjfrNXkoR7wbGSSckX1ZBQArf4c6eFOq
S6PAaYaDVWtkiZJqCm82LodUaf65/OnNQkiJ9dpqOg6Nm+AZ1iU3o37zwi9LtyeH
PM2v/xyNyZDKDLQBQRpt0ZPy/k53/SGEmVxeA2ifcsVMHv+ZSR/wm/s+U3iPvMT1
QJj2GtTsfbAOOiDA4Erp8qdrr1t0WeTl48oYWZGYK7kkY1sTs4+2RachYY2rjPwV
ax5UXGYO0sfrNfWB2XpDUoD6i1dyeXRLAMyisbebdAe0ilzdVU5QIlhp5K7qKbEk
tfMSBuHNrKM=
=wyln
-----END PGP SIGNATURE-----

--=-SF5qZ+C8qTk8UFVjYyI5--
