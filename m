From: Christophe Saout <christophe@saout.de>
Subject: Re: [Fwd: [Bug 3003] New: might_sleep warning when setting up
	IPSec with IPCOMP]
Date: Fri, 02 Jul 2004 19:58:32 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088791112.2085.4.camel@leto.cs.pocnet.net>
References: <40E5A1B3.2020202@us.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-UfxZsYW81H+P/zsMcMNm"
Cc: James Morris <jmorris@intercode.com.au>, akpm@osdl.org,
        netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
In-Reply-To: <40E5A1B3.2020202@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-UfxZsYW81H+P/zsMcMNm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Am Fr, den 02.07.2004 um 10:56 Uhr -0700 schrieb Nivedita Singhvi:

> Looks like deflate_comp_init() is not calling
> __vmalloc in a kosher way.
>
> [...]
> Jul  2 18:39:04 websrv [<c0139fbc>] kmem_cache_alloc+0x5c/0x60
> Jul  2 18:39:04 websrv [<c0147bc0>] __get_vm_area+0x20/0xf0
> Jul  2 18:39:04 websrv [<c0147cb4>] get_vm_area+0x24/0x30
> Jul  2 18:39:04 websrv [<c0147f1c>] __vmalloc+0x3c/0x100
> [...]

__get_vm_area does a

area =3D kmalloc(sizeof(*area), GFP_KERNEL);

So it will produce a warning no matter what flags are passed to
__vmalloc.


--=-UfxZsYW81H+P/zsMcMNm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: Dies ist ein digital signierter Nachrichtenteil

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)

iD8DBQBA5aJIZCYBcts5dM0RAlcfAJ92Fy+O5RmW4kE1PgLJYaQjg+Q/0ACgrXl4
w4jVpG55UVBnTV/wDspsCXE=
=L3aE
-----END PGP SIGNATURE-----

--=-UfxZsYW81H+P/zsMcMNm--
