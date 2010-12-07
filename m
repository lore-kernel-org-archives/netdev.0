From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Tue, 7 Dec 2010 12:00:39 +1100
Message-ID: <20101207120039.6ea1491e.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__7_Dec_2010_12_00_39_+1100_wKWHfWrMxxKJQ3v_"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	Breno Leitao <leitao@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__7_Dec_2010_12_00_39_+1100_wKWHfWrMxxKJQ3v_
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

drivers/net/ehea/ehea_main.c: In function 'ehea_refill_rq1':
drivers/net/ehea/ehea_main.c:405: error: implicit declaration of function '=
ehea_info'
drivers/net/ehea/ehea_main.c: In function 'ehea_init_fill_rq1':
drivers/net/ehea/ehea_main.c:429: error: implicit declaration of function '=
ehea_error'
drivers/net/ehea/ehea_main.c: In function 'ehea_neq_tasklet':
drivers/net/ehea/ehea_main.c:1306: warning: format '%lx' expects type 'long=
 unsigned int', but argument 2 has type 'u64'

Caused by commit 539995d18649023199986424d140f1d620372ce5 ("ehea: Use the
standard logging functions") interacting with commit
5c7e57f7cddb83d81d83fefa5822dfe80891130e ("ehea: Add some info messages
and fix an issue") which went into Linus' tree before 2.6.37-rc4.

Presumably a merge of net-current into the net tree will need a fixup patch.

I have used the net tree from next-20101206 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__7_Dec_2010_12_00_39_+1100_wKWHfWrMxxKJQ3v_
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJM/Yc3AAoJEDMEi1NhKgbskQAH/A1Oco8rh1BwBvmKpGU0tfCX
DfIozyA7lkhMOggpZptCnpCgjgPHwC0OjV1vkfF6tSnnUUqPPq4xrsVE17Az0p+C
K8PfqtfnYGJg0gJeqoxiQFfFOXKJBgrqk0No6f0lh+oFpGtDamBVFiGFoos83Dil
NinJ8C9i5EbkDdlLYwrzS6v/+q0ev88BwpcX0AcIlVhvvzTzT8do8VS7JpYcSFdr
BE72PJ9F28FBwIrpFprXQNrOohDFM/f1PEmWVYtSo2f74gUeNVcgl/Nm3FxK+yVP
gDZDWkZnmo7EOfAo7eCnSKZIoQWFzMBXCW22T5x2DouYRyNcxwKWgs7vJAaMG8Y=
=SrfO
-----END PGP SIGNATURE-----

--Signature=_Tue__7_Dec_2010_12_00_39_+1100_wKWHfWrMxxKJQ3v_--
