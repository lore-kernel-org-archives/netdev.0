From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the pci tree
Date: Tue, 4 Jan 2011 13:28:47 +1100
Message-ID: <20110104132847.de49be89.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__4_Jan_2011_13_28_47_+1100_UUs6wAdx1GWG05ah"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jon Mason <jon.mason@exar.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	stephen hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__4_Jan_2011_13_28_47_+1100_UUs6wAdx1GWG05ah
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/skge.c between commit
1d3c16a818e992c199844954d95c17fd7ce6cbba ("PCI: make pci_restore_state
return void") from the pci tree and commit
7dbf6acdbad2fbc6eea72b58404461dcb7c6d9d2 ("skge: Do not use legacy PCI
power management") from the net tree.

The latter removes the code modified by the former, so I used the latter.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__4_Jan_2011_13_28_47_+1100_UUs6wAdx1GWG05ah
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJNIoXfAAoJEDMEi1NhKgbsIdoH/jG8Bf8qBF3eRqkmn2eThoHq
w5G3XAXiDXNtwa8LSNvt68tZutIivWGT0COhqe47zGajlgKjshAji2dfdVdsAWC2
SSpFLQkn7r9cXZMcTDoSM2hZzC/+IJMhMmBolsH6dZVBCPe5KMCJkHgjCeVvb8sI
LrxG6w9j4DPvmiV+kGv4/Z5hEpBI+p8uPHuGWtnnsN+J/lN133zHVBYYwGVtRm4j
6sAccIvBCEdPxnugGyTfgiE+2foQ8uFtgKqFET2SOee4r3alotxWysuesDLYhghe
DuZoSPXhhVSeJmkv0giP73uy5vI8tqvU2W+30VSdhKEDyKYCgTwh3HI3xRizqTU=
=8aXW
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Jan_2011_13_28_47_+1100_UUs6wAdx1GWG05ah--
