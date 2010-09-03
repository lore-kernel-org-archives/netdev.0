From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Fri, 3 Sep 2010 11:47:50 +1000
Message-ID: <20100903114750.3d8994b7.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__3_Sep_2010_11_47_50_+1000_0n8nWaz3mj88hjRQ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__3_Sep_2010_11_47_50_+1000_0n8nWaz3mj88hjRQ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, next-20100830 and later builds (s390
allmodconfig) failed like this:

drivers/net/stmmac/stmmac_main.c: In function 'stmmac_adjust_link':
drivers/net/stmmac/stmmac_main.c:217: error: implicit declaration of functi=
on 'readl'
drivers/net/stmmac/stmmac_main.c:270: error: implicit declaration of functi=
on 'writel'
drivers/net/stmmac/stmmac_main.c: In function 'stmmac_dvr_probe':
drivers/net/stmmac/stmmac_main.c:1676: error: implicit declaration of funct=
ion 'ioremap'
drivers/net/stmmac/stmmac_main.c:1676: warning: assignment makes pointer fr=
om integer without a cast
drivers/net/stmmac/stmmac_main.c:1744: warning: cast from pointer to intege=
r of different size
drivers/net/stmmac/stmmac_main.c:1760: error: implicit declaration of funct=
ion 'iounmap'

Exposed by commit ac75791aa943c7953521cb4fa7728bf51f9abd2d ("stmmac:
remove dead option in the driver's Kconfig")  That allowed the driver to
be built on a lot more platforms that previously.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__3_Sep_2010_11_47_50_+1000_0n8nWaz3mj88hjRQ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMgFPGAAoJEDMEi1NhKgbsQHMH/jk/JpQC41NE2lWG3UH1fq4r
LF2l9zEKijpYNPK5vvNsyNgmkD6QHhq8R+2ukmqKzf3xA5OghdBgcmLvd1+SlB4f
mb8bjmfXNTLV5n8I1o5vKirRdbvRUFdidEZa0KyrMj9ggWj4fuLaC1kRzBsi2pwq
6dsoXOV4JMqrtC4nDJP9CvkXkkyYCAPne3E73t+0EmQs1pqVT6K+VsXnmoBJpKny
N1oZJSALVKhK5NbFTPzoF1q8H3pa1sRs43jPI5B//Oz9Xdc5XCUKBLPA+f1Jy5jm
Vtwmj5Bxj5VkMlZJHHWcLNrv5zos1JuILEDoieMqt7NChq5buSL9WyhVBYTO+bo=
=Mqn7
-----END PGP SIGNATURE-----

--Signature=_Fri__3_Sep_2010_11_47_50_+1000_0n8nWaz3mj88hjRQ--
