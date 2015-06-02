From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the scsi tree with the net-next tree
Date: Tue, 2 Jun 2015 17:31:27 +1000
Message-ID: <20150602173127.3b65697f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/YnLY2x=ILBBl22xtrP5jo.H"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bart Van Assche <bart.vanassche@sandisk.com>
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/YnLY2x=ILBBl22xtrP5jo.H
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi James,

Today's linux-next merge of the scsi tree got a conflict in
drivers/target/target_core_user.c between commit 5538d294dd66
("treewide: Add missing vmalloc.h inclusion") from the net-next tree
and commit 7ad09a15e76b ("target: Minimize SCSI header #include
directives") from the scsi tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/target/target_core_user.c
index edc955558250,21b438ec4700..000000000000
--- a/drivers/target/target_core_user.c
+++ b/drivers/target/target_core_user.c
@@@ -19,13 -19,13 +19,14 @@@
  #include <linux/spinlock.h>
  #include <linux/module.h>
  #include <linux/idr.h>
+ #include <linux/kernel.h>
  #include <linux/timer.h>
  #include <linux/parser.h>
 +#include <linux/vmalloc.h>
- #include <scsi/scsi.h>
- #include <scsi/scsi_host.h>
  #include <linux/uio_driver.h>
  #include <net/genetlink.h>
+ #include <scsi/scsi_common.h>
+ #include <scsi/scsi_proto.h>
  #include <target/target_core_base.h>
  #include <target/target_core_fabric.h>
  #include <target/target_core_backend.h>

--Sig_/YnLY2x=ILBBl22xtrP5jo.H
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVbVvTAAoJEMDTa8Ir7ZwVX68QAJP7k2cDFXi6hziDPsPe0j1B
eexNEJxvWr9X5eEtiLHjNHKnP3T5oZwSBImqgKxRusQXgXzbGVOkY6zbOo5ewug8
Tl7zdjpcO5J9ONfuIJv7svJwhDQerbhSKIN3w2XsPuUTxbXhUzckC6gEOfKX01VC
A+ZJHPMkzF9Fk+fMPuJQcyBQXxx6s7B3DTwTceVI7GAtaBYHywBnF355zi8l9j0a
19LVG7h7erJhkX/15Y0s0oxqONQewowrtIjkX4M0PsBTqo1lBsgnitptqS6YGcAC
OQ0U85/b+H7GmvstyIemyeLSpJhNZD1Dkq56nl7jtYYamLmrdoptmsseH2eP1aD3
KcWuuUiBtGfmFAhRcJIHZmv6VGVEOIOx7hFsOxcCSnxPHCzkfoIOJjjqu/UMVRKK
uvaYoa6xbSnWq+RjhdxJ+0ejSckpm/8RG04XQJ9hy/z7VAzAiua3a5eL/Yn14xHU
3C9IOFcxGJ3mc9MI45h174UmIWctodoJg0N3vz88P/tJ644ItePD4FwG1FJjxfT7
2R0xHytx16djquCIqgLWyYVW2N9H7UeSdc9/W5p5l5Wi5IS6OFtHllEyY5GCV4z9
hP9vxNwWP9Ne5FgiRKef+bU94UDqzdmX8OwQeuBwwL3Rg0F2bU6vDucmdl/KBk4p
7riZhaDN+IT2cZk2VObz
=OQsP
-----END PGP SIGNATURE-----

--Sig_/YnLY2x=ILBBl22xtrP5jo.H--
