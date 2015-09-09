From: Corinna Vinschen <vinschen@redhat.com>
Subject: Re: [PATCH net 1/1] r8169: fix sleepable allocation during netdevice
 stats retrieval.
Date: Wed, 9 Sep 2015 17:55:11 +0200
Message-ID: <20150909155511.GD19913@calimero.vinschen.de>
References: <55E9A518.3080906@gmail.com>
 <20150904.113657.2146226970417029162.davem@davemloft.net>
 <20150904205904.GA32346@electric-eye.fr.zoreil.com>
 <20150906101954.GE30539@calimero.vinschen.de>
 <55ED391C.2090906@gmail.com>
 <20150907085023.GA17511@calimero.vinschen.de>
 <55EDA281.3030706@gmail.com>
 <55EE81D8.4010008@gmail.com>
 <55F04F40.4040901@gmail.com>
 <20150909155404.GC19913@calimero.vinschen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="eqp4TxRxnD4KrmFZ"
To: poma <pomidorabelisima@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Mike Massonnet <m8t@gandi.net>,
	Benedikt Meurer <benedikt.meurer@unix-ag.uni-siegen.de>,
	Bernhard Walle <bernhard.walle@gmx.de>,
	Hendrik Scholz <hscholz@raisdorf.net>,
	Florian Rivoal <frivoal@xfce.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-n.franken.de ([193.175.24.27]:52960 "EHLO
	mail-n.franken.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbbIIPzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 11:55:13 -0400
Content-Disposition: inline
In-Reply-To: <20150909155404.GC19913@calimero.vinschen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--eqp4TxRxnD4KrmFZ
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sep  9 17:54, Corinna Vinschen wrote:
> On Sep  9 17:24, poma wrote:
> > [PATCH net] r8169: Fix sleeping function called during get_stats64
> > http://marc.info/?l=3Dlinux-netdev&m=3D144180123410135&q=3Draw
> > - the noise is still present
>=20
> Are you really sure?  The entire dma_alloc/dma_free stuff has been moved
> away.  There's no locking or sleeping involved different from what was
> there before my original patch when calling .ndo_get_stats64.
>=20
> How would I be able to reproduce this on the command line?

It would also be interesting to see the "noise" as it looks after
applying the above patch...


Corinna

--eqp4TxRxnD4KrmFZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJV8FZeAAoJEPU2Bp2uRE+g+0IP/jRbYVEX8p6I61V4TAfW5R6V
itv5IE6c69RjC+a6xXn3TipnVnzQUGt0NztLbS4o6wuzqLwna5qeloPSSRMOZSg0
5OEuADVCpzqsTfzBXt3xYYFejsZf33HSw7w9YRdjdKw5Bvf80JtQ/eNy9AzhTNKZ
sM8MvsQ3dH1eKjpJEYAW9jNqGBwcfd+1F2aTZpMuxStGLhU0y80q1x0IsCsmL4Nn
DJxotyVaoiskag86yxslkFLPS8aHIoQJ6wnu2tUB2tZTBdnMLlaBvwmtK2vxBOZo
/w1D4vPoqREZTNrc3wELNCaKWm2+31kpJHcNCND7vCLr2DQ1+A62pgMgxEhtL6z1
/2tJ69pthwX8N5D512WuT5/4kZ+3qBGz3hGqgQBzKhJEQwsj6eIKn5W91EeivMwd
CuWxuNilYerXOrO3sjhoMzPY82jVXWb+iW4MdAw5j+hPJnOqeFdDVR6TsEDUkIW5
pfQa8CPFkZsY0VVtVhFsDp8jHKcLQwCA14sty7VY5Or01d4bqlkKted+CgHhLgFI
w+BGaBkw+43xidduAhRmMDSV7YouDEzaiXp6CQ4Ia7sdvGqNI3IsCUl2FALgB9qo
HAHrhN0t59mqxPEpE9J5dVt4c6EXcYQfJ41BkGemuN7XTcKUmIdlWMadrxfheXvR
/PHAT/3c+q39N8cOohzn
=8dDX
-----END PGP SIGNATURE-----

--eqp4TxRxnD4KrmFZ--
