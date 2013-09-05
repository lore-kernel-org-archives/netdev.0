From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [GIT PULL] please pull infiniband.git
Date: Thu, 5 Sep 2013 10:31:16 +1000
Message-ID: <20130905103116.6998495cd755f5ae2c3def78@canb.auug.org.au>
References: <1378314218-28021-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__5_Sep_2013_10_31_16_+1000_YHieQfqkJ8.BSg=6"
Cc: Roland Dreier <roland@kernel.org>, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378314218-28021-1-git-send-email-roland@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__5_Sep_2013_10_31_16_+1000_YHieQfqkJ8.BSg=6
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

On Wed,  4 Sep 2013 10:03:38 -0700 Roland Dreier <roland@kernel.org> wrote:
>
> Please pull from
>=20
>     git://git.kernel.org/pub/scm/linux/kernel/git/roland/infiniband.git t=
ags/rdma-for-linus

I am carrying the following merge fix patch for a semantic conflict
between this tree and Dave's net-next tree:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Tue, 13 Aug 2013 13:01:49 +1000
Subject: [PATCH] cxgb4: fix up for bond_for_each_slave API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/=
ethernet/chelsio/cxgb4/cxgb4_main.c
index 038df4b..b6ad557 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3982,7 +3982,6 @@ static int cxgb4_inet6addr_handler(struct notifier_bl=
ock *this,
 	struct inet6_ifaddr *ifa =3D data;
 	struct net_device *event_dev;
 	int ret =3D NOTIFY_DONE;
-	int cnt;
 	struct bonding *bond =3D netdev_priv(ifa->idev->dev);
 	struct slave *slave;
 	struct pci_dev *first_pdev =3D NULL;
@@ -3996,7 +3995,7 @@ static int cxgb4_inet6addr_handler(struct notifier_bl=
ock *this,
 		 * in all of them only once.
 		 */
 		read_lock(&bond->lock);
-		bond_for_each_slave(bond, slave, cnt) {
+		bond_for_each_slave(bond, slave) {
 			if (!first_pdev) {
 				ret =3D clip_add(slave->dev, ifa, event);
 				/* If clip_add is success then only initialize
--=20
1.8.4.rc0

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Thu__5_Sep_2013_10_31_16_+1000_YHieQfqkJ8.BSg=6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSJ9DZAAoJEECxmPOUX5FErgAQAIr4ZdTeSK8gbK9FQ/H0Ii9Q
STGyO3wNk2vGpE3y9L11oDqIU5fS0xKSXqNZKxfZXPE0+ZOCISFHcmo+AqFnbqnw
CRgvDXkV4yb+ZGgc30pXE9WyYi+FqE3e868sBEOo/wISUjitP5k5GC/RQ2Nn9Trl
9dzngMkQcsw9bauKoKuLeTtHgt7FQ5bhVm3QnfUPxoVvuJ3YJURYCnEr8x8NipVn
I+UFvjMC/+sJj9Ih7zV8q4CkDNn4Po3/O0Dz+QIA/y/pnZYYmNgrs216snmYT6J6
N3zHXcwcCrACXIeCPLDffs2qM9eFxeozkepBPPTxOILJRm+6xpbUPv3x6eqHYVPH
kNRr5dsRnJw0AQbPycD7pHzPoZk6aoD/qJm+Bpi3qO8JZleqQdDHb+EqAM7vtXDZ
dtt01SZzYHQtxDPOSWfnEXu/TbEq6gUfS+NwUmDr9d+mTMIxgdYTL8cS1mV4fmzE
75zTQzbKdpT/W6fKSMMKixq7W4nN0xsDRZ29JMYiVI4rZiy3shVLZ1f+o5223aSj
b/U3GYfSWDJA3/K0snfW/lRGJ0B5D/TCh8KA8VhN2yRcDT3XLE6x0XTPW8MBajjW
OL6uZSutnlLIzL9DI6hAwTQiCjj653Xnmxhh2a/OWyur+IYXpwtpPF/3gtGLUK1p
Lkf78AmYZMcwusm+gRcF
=stM7
-----END PGP SIGNATURE-----

--Signature=_Thu__5_Sep_2013_10_31_16_+1000_YHieQfqkJ8.BSg=6--
