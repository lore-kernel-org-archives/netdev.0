From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [PATCH 07/26] net/mlx4_core: constify local structures
Date: Mon, 12 Sep 2016 07:59:54 +0300
Message-ID: <20160912045954.GD8812@leon.nu>
References: <1473599168-30561-1-git-send-email-Julia.Lawall@lip6.fr>
 <1473599168-30561-8-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="fXStkuK2IQBfcDe+"
Cc: Yishai Hadas <yishaih@mellanox.com>, joe@perches.com,
        kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1473599168-30561-8-git-send-email-Julia.Lawall@lip6.fr>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fXStkuK2IQBfcDe+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 11, 2016 at 03:05:49PM +0200, Julia Lawall wrote:
> For structure types defined in the same file or local header files, find
> top-level static structure declarations that have the following
> properties:
> 1. Never reassigned.
> 2. Address never taken
> 3. Not passed to a top-level macro call
> 4. No pointer or array-typed field passed to a function or stored in a
> variable.
> Declare structures having all of these properties as const.
>
> Done using Coccinelle.
> Based on a suggestion by Joe Perches <joe@perches.com>.
>
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Thanks,
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>

--fXStkuK2IQBfcDe+
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX1jZKAAoJEORje4g2clinROEP/A4Y4Yc31UUOjQwA93Qpw7Ge
z1jVLNhbKVrB2Tx1O/0AUhmMQMX8WdRDZ1QkbNDBI06ueUvOfVlyvWibzXblL2ZX
uTYmLAl136G1vwiL1TthzIxGr3oXI9cu4nhzSuUKdCQOCDEXlUdipBghMWL9K1bk
I3mA2mAMhF5lC6y9jzvyRuLIbsH6kPmOADnFDFKyO6sXupigMnPfABDMn4I57A2K
jVXiWf0IgzJA24p3rp/uC5PaIAGhi+i8l/FDWvKIH5uFkwvchlq+7OF/C/xoNUey
y/u6XmPBamihJRyAzkBn2CxSGCkiz4rEVvz0J/MDLBpQ+vd912kJ7bwCSMZ9GWb+
RqJBZ5A3t4/d5bSLgTjj9vI1w7RXnS88IR/U8MfNlAOtwg+aHssN6MIi5Niapp3f
KhCPhNUsI0/+Sk0S41Tfu2HE0kjZ7LPFlMilz1hiPHXr86pWwJata2RD+FDy0UEv
05In0AME3ko0QuLup+igoTkKZ4si44m+wWZffadWfyomZIG07wC5omSpY9Rw4U7j
j1YPTpcN4JjLxoSXgdychup8ZJt8Sqj6NXRL+DbVXi8/MdK0oR1GSQeOwHerzNgC
8GubfFFXaViDCYysXe11MdPnKOjHq6Me2mSVtcp0rC2YtC4D5y/oQ5nhSBS6eAsB
ablnAYST6aiPdBvMsI7V
=1frQ
-----END PGP SIGNATURE-----

--fXStkuK2IQBfcDe+--
