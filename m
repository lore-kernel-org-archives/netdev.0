From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-current tree with the
 scsi-rc-fixes tree
Date: Tue, 5 Jan 2010 08:56:13 +1100
Message-ID: <20100105085613.0a04d952.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__5_Jan_2010_08_56_13_+1100_AIzazKV4QIJg_Q7."
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Rakesh Ranjan <rakesh@chelsio.com>,
	James Bottomley <James.Bottomley@HansenPartnership.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__5_Jan_2010_08_56_13_+1100_AIzazKV4QIJg_Q7.
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-current tree got a conflict in
drivers/scsi/cxgb3i/cxgb3i_offload.c between commit
44214ab474671e1ab5a860954db413bce52f7e04 ("[SCSI] cxgb3i: Fix a login
over vlan issue") from the scsi-rc-fixes tree and commit
52ee264bca378835decb827d18b1d90b709ca4c9 ("cxgb3i: Fix a login over vlan
issue") from the net-current tree.

These seem to be different version of the same change.  The version in
the net-current tree looks wrong - it contains

if (dev->priv_flags && IFF_802_1Q_VLAN)

but it presumably should be

if (dev->priv_flags & IFF_802_1Q_VLAN)

as in the scsi-rc-fixes version.

I used the version from the scsi-rc-fixes tree (even though it is dated
12 days earlier). (There was also a comment format difference.)
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__5_Jan_2010_08_56_13_+1100_AIzazKV4QIJg_Q7.
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAktCY/0ACgkQjjKRsyhoI8zHKwCffmgbQwdLadrWTPJx+WOdjc14
ldIAnRqbngu7VC1fU6BNlVMsFiYjEY1L
=EgUd
-----END PGP SIGNATURE-----

--Signature=_Tue__5_Jan_2010_08_56_13_+1100_AIzazKV4QIJg_Q7.--
