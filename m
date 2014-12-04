From: Felipe Balbi <balbi@ti.com>
Subject: Re: am335x: cpsw: interrupt failure
Date: Thu, 4 Dec 2014 10:56:09 -0600
Message-ID: <20141204165609.GJ18045@saruman>
References: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="pMCBjikF2xGw87uL"
Cc: netdev <netdev@vger.kernel.org>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, Felipe Balbi <balbi@ti.com>
To: Yegor Yefremov <yegorslists@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:36035 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932482AbaLDQ4I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2014 11:56:08 -0500
Content-Disposition: inline
In-Reply-To: <CAGm1_ksPkFXV_S6541cK1TQb_eRTHbspZy4zWxY5GMrrjGD2tA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--pMCBjikF2xGw87uL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Dec 04, 2014 at 05:41:38PM +0100, Yegor Yefremov wrote:
> I have following problem. My systems reboots at high network load
> after this commit (found via git bissect):
>=20
> commit 55601c9f24670ba926ebdd4d712ac3b177232330
> Author: Felipe Balbi <balbi@ti.com>
> Date:   Mon Sep 8 17:54:58 2014 -0700
>=20
>     arm: omap: intc: switch over to linear irq domain
>=20
>     now that we don't need to support legacy board-files,
>     we can completely switch over to a linear irq domain
>     and make use of irq_alloc_domain_generic_chips() to
>     allocate all generic irq chips for us.
>=20
>     Signed-off-by: Felipe Balbi <balbi@ti.com>
>     Signed-off-by: Tony Lindgren <tony@atomide.com>
>=20
> and I get following error messages:
>=20
> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0

irq 0 ? Weird, that's not a valid IRQ.

> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
> ->action():   (null)
>    IRQ_NOPROBE set
>  IRQ_NOREQUEST set
> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
> ->action():   (null)
>    IRQ_NOPROBE set
>  IRQ_NOREQUEST set
> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
> ->action():   (null)
>    IRQ_NOPROBE set
>  IRQ_NOREQUEST set
> irq 0, desc: cf004000, depth: 1, count: 0, unhandled: 0
> ->handle_irq():  c0087fc0, handle_bad_irq+0x0/0x258
> ->irq_data.chip(): c08e7174, no_irq_chip+0x0/0x68
> ->action():   (null)
>=20
> My system: am335x with fast ethernet on the first slave and gigabit
> Ethernet on second CPSW slave. This issue occurs, when I ran nuttcp
> with default settings.
>=20
> With commit above I can at least see these messages, but 3.18-rc7 for
> example reboots without any messages.
>=20
> Any idea?

if you take v3.18-rc7 and just revert that commit, does the problem go
away ?

--=20
balbi

--pMCBjikF2xGw87uL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUgJIpAAoJEIaOsuA1yqREYM4P/j8wd0dB1U75U6AZxxTsZJ2L
eGPVq7QYjbOjOI46kIFi8TrtF2QDS8ecQybhV940Ons97sQrhOdW5wqtDmrwnrCQ
lno8XLFsVqvBGJG5oxxyUEO7Ruj8o37oMQ/4iecsvI0P21MriY1mTmd05emuvJE0
tJ/Y9iDZol1ZCaOPPYrzPkBxeQvZ0iXv4Vpbk3xGLzclhiJcsZd/YDlob15t1R9b
yIz+Wm43VFFSCwl4TWhR4WB4tRjFe8scfLuXCTsm+n5/0fcda8oCTUh/7mey0NUR
I4BrkM/PkDIKu6H8IGGK0RErTpusKxbvK+taabKLoFA7aWixo+K2/EHkUgeHPGeG
SKepUMo54lONMKe9JIy1Dy2pMYQdNDjWjX3l+47qJDxTOMIZ+AQL82CN3/0n+CKs
lu096FVN4gwbXEgWIXwfHJ1ZZHXOVRb5ktjz7hm04XPgtQFyXmYmqaxaLseS0Qpa
uCfW0Qs1UQQaZF8akvjT970oLxQcSihOprxTVkc+Y1f2HYCs3ILMv4j8OK+2oP0I
4mS1mvxmfmpfKT9GWaZkhyfKfftjbXc4gMHtwzXSSu6RiXRAF0j0JVMJjUz3a4Na
tdBBiTYwRqStw/YSnniljjJxbNZGjNWDtL5vzbtZubfHyE5SXgrJI3R63fUMPB4t
cG8G5UAdEpyYizZ34/7J
=f5Rr
-----END PGP SIGNATURE-----

--pMCBjikF2xGw87uL--
