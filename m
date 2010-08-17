From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless tree with Linus' tree
Date: Tue, 17 Aug 2010 11:52:03 +1000
Message-ID: <20100817115203.e8a76e44.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__17_Aug_2010_11_52_03_+1000_f9fD2nJTg4H4nnlC"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Dan Williams <dcbw@redhat.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	libertas-dev@lists.infradead.org, netdev@vger.kernel.org,
	Takashi Iwai <tiwai@suse.de>
To: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__17_Aug_2010_11_52_03_+1000_f9fD2nJTg4H4nnlC
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless tree got a conflict in
drivers/net/wireless/libertas/if_sdio.c between commit
886275ce41a9751117367fb387ed171049eb6148 ("param: lock if_sdio's
lbs_helper_name and lbs_fw_name against sysfs changes") from Linus' tree
and commit 3d32a58b87cd251b50842f93b87d5458061c0cfc ("libertas: [sdio]
use common firmware request helper and new firmware locations") from the
wireless tree.

OK, I can't quite figure out what is going on here.  The latter commit
removes that code that was modified by the former, so I effectively
reverted the former commit (by using this file from the wireless tree)
since the "helper" and "firmware" fields of struct if_sdio_card don't
seem to be used anywhere anymore.  Can they be removed as well?
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__17_Aug_2010_11_52_03_+1000_f9fD2nJTg4H4nnlC
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMaetDAAoJEDMEi1NhKgbsRhQIAIB8A2VzaoVXsUqtHjO40sNk
k2TMIrioH6v5PvgR6KW1Cwy/ZHhDfksv/ksJ11Jwj46oBqGh25MpIrPUUTMMwGMs
byZAMzPV/BZ6zpFOvBxbL/HN8Cy4QEfkNa1NkwWIvBSJwtQoWZT1Vo/mDShJgTBr
g6+3ul31pUdoWnIl8Pm+etG8nb7MWWkRoGyss7b5P7VwWch6qXNE2jsNHBQDyBlr
qMMJw+SVOr2v/QnQHa6l70hbj42VuzAFv0Pz9SsBhzs6khi+mfwrJdWK2+M4DJUc
mOsm3McJ5+4DhiHp1JbnlXyXNQDrDemXSc0MbRct4JMRb6pzkR7C9vWl/Q8apW8=
=dvps
-----END PGP SIGNATURE-----

--Signature=_Tue__17_Aug_2010_11_52_03_+1000_f9fD2nJTg4H4nnlC--
