From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the
 net-next tree
Date: Fri, 27 Sep 2013 13:19:05 +1000
Message-ID: <20130927131905.350178dc624c4f0a8ede2269@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__27_Sep_2013_13_19_05_+1000_g=ApjMuLSzaLC.TF"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Catalin Iacob <iacobcatalin@gmail.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__27_Sep_2013_13_19_05_+1000_g=ApjMuLSzaLC.TF
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
drivers/net/wireless/rtlwifi/rtl8192ce/phy.h between commit a958df5dc306
("rtlwifi: Remove extern from function prototypes") from the net-next
tree and commit 3a1ea9fd9351 ("rtlwifi: remove duplicate declarations and
macros in headers") from the wireless-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
index f8973e5,80a0893..0000000
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/phy.h
@@@ -217,10 -222,10 +215,9 @@@ void _rtl92ce_phy_lc_calibrate(struct i
  void rtl92c_phy_set_rfpath_switch(struct ieee80211_hw *hw, bool bmain);
  bool rtl92c_phy_config_rf_with_headerfile(struct ieee80211_hw *hw,
  					  enum radio_path rfpath);
 -bool rtl8192_phy_check_is_legal_rfpath(struct ieee80211_hw *hw,
 -					      u32 rfpath);
 +bool rtl8192_phy_check_is_legal_rfpath(struct ieee80211_hw *hw, u32 rfpat=
h);
- bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
  bool rtl92ce_phy_set_rf_power_state(struct ieee80211_hw *hw,
 -					  enum rf_pwrstate rfpwr_state);
 +				    enum rf_pwrstate rfpwr_state);
  void rtl92ce_phy_set_rf_on(struct ieee80211_hw *hw);
  bool rtl92c_phy_set_io_cmd(struct ieee80211_hw *hw, enum io_type iotype);
  void rtl92c_phy_set_io(struct ieee80211_hw *hw);

--Signature=_Fri__27_Sep_2013_13_19_05_+1000_g=ApjMuLSzaLC.TF
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.21 (GNU/Linux)

iQIcBAEBCAAGBQJSRPkyAAoJEMDTa8Ir7ZwVgaUP/1mIN2BQoGOINP93F2IRTJlG
DhPFPJMXvZaanRTWOjHLEa/mnuVKDPRma8VtAT4nOrMJeOHCP0Z+tWlpQMExiIOt
pymjiSL4+GJ7PUMH6bYxfO3J+ipSPXVFqR9754NB/zUss7Q69PTEPAEO+w4dYCQf
Nza26Ffp6zz51XhjY/5RizBkDpEJKR7VJVB+B2SlARQiYtcqD3azjnF4YUgT3jMf
nLkjiUOODuO0HSU1cd2KLfHVUjWAhhzlIP+SZEUxCT5PVkPE40empx/PVkAx0ZQG
bhfVnn6SyVA5wTk+AA0WqOJ61vtocl9nCBzfWzZ4e0RwhrAwfoBcW4jQnJYttnGh
4fQPRhdsZgawqpOYLzvovzVaBn8pbERx6D+jdP8RjK7REWZNHWY1ydpmvebjwZm+
+4qSKW9Ml73/n6xn20wfLQn1PGWCCcN4+Z55HUz+ACTJTtOT4roQd+z+d7sA09yx
nngFaFmVZMU1ZponzgZCAnXvsJohcp434iqak+AoCh6DqAAxrwaIn5+yRVRRNNEm
hnH81JgrfECS8CsyDoBZWRGd5WWPgq8S3WSe0aTlFeqlLGYeMox9ztZg98bwtA75
GFodio/drOUU76fySo9qIbWFkODuywGaAZV1BsC3HgskXZEOOw/g25j3mnl3p+aV
TBxQjwFJWJI0rTb+nzj6
=S9DA
-----END PGP SIGNATURE-----

--Signature=_Fri__27_Sep_2013_13_19_05_+1000_g=ApjMuLSzaLC.TF--
