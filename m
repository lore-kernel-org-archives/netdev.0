From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the net-current tree
Date: Tue, 17 May 2011 12:01:04 +1000
Message-ID: <20110517120104.35ff4055.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__17_May_2011_12_01_04_+1000_MztEuKnDHFzbTGmn"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Thomas Jarosch <thomas.jarosch@intra2net.com>,
	=?UTF-8?B?Ik1pY2hhxYIgTWlyb3PFgmF3Ig==?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__17_May_2011_12_01_04_+1000_MztEuKnDHFzbTGmn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/vmxnet3/vmxnet3_ethtool.c between commit ebde6f8acba9
("vmxnet3: Fix inconsistent LRO state after initialization") from the
net-current tree and commit a0d2730c9571 ("net: vmxnet3: convert to
hw_features") from the net tree.

I fixed it up (by removing the lines added by the net-current patch) and
can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__17_May_2011_12_01_04_+1000_MztEuKnDHFzbTGmn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJN0dbgAAoJEDMEi1NhKgbsoe4H+weo9kAe4zoDJlGHZ7oRCifA
Knd1XdB/1KuDcC11tQI6Ooa9nYc5CFAk1hxDE/RorhkED08Ufp2Tcs6cqzDvLNuT
CTZI0GZy+WDonepZzIfzEyEzeryFdu+oHEDly3wLACdWRrsIk5AW8y3RdwAXOG+F
6loqlN9WOE47jDULjT/GCHVP5mtro23Ba5y4p53D2XMp83xyjMlHFkuWlqpcjU8F
h+tWsuGPw3euxUlDXEnkvlySmgy2Wi+BPkt90yfJLxoudyOcidoCSJiU/B7tUEp7
IloRw2g0rqQSysxjt3vCDFq9JgCbUKlEzMpre+a5dTxcNFoGO0BzfbH12FULr+Y=
=C393
-----END PGP SIGNATURE-----

--Signature=_Tue__17_May_2011_12_01_04_+1000_MztEuKnDHFzbTGmn--
