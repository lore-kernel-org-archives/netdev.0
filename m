From: =?UTF-8?Q?Christoph_B=c3=b6hmwalder?= <christoph@boehmwalder.at>
Subject: [PATCH RESEND] wireless: iwlwifi: fix minor code style issues
Date: Mon, 25 Sep 2017 13:37:13 +0200
Message-ID: <912deca9-79b6-7a44-6859-dbe532d90fed@boehmwalder.at>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="pW4qBsv3Puj2Rn27l1vfQ7lNEcWe0732q"
Cc: =?UTF-8?Q?Christoph_B=c3=b6hmwalder?= <christoph@boehmwalder.at>
To: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
        luciano.coelho@intel.com, kvalo@codeaurora.org,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, trivial@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--pW4qBsv3Puj2Rn27l1vfQ7lNEcWe0732q
Content-Type: multipart/mixed; boundary="gRmwerBN0hJlqwNjP1ShQwXtoR00B893K";
 protected-headers="v1"
From: =?UTF-8?Q?Christoph_B=c3=b6hmwalder?= <christoph@boehmwalder.at>
To: johannes.berg@intel.com, emmanuel.grumbach@intel.com,
 luciano.coelho@intel.com, kvalo@codeaurora.org,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, trivial@kernel.org
Cc: =?UTF-8?Q?Christoph_B=c3=b6hmwalder?= <christoph@boehmwalder.at>
Message-ID: <912deca9-79b6-7a44-6859-dbe532d90fed@boehmwalder.at>
Subject: [PATCH RESEND] wireless: iwlwifi: fix minor code style issues

--gRmwerBN0hJlqwNjP1ShQwXtoR00B893K
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable

Fixes three trivial issues as reported by checkpatch.pl, namely two
switch/case indentation issues and one alignment issue in a multiline
comment.

Signed-off-by: Christoph B=C3=B6hmwalder <christoph@boehmwalder.at>
---
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
b/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
index 99676d6c4713..ccdb247d68c5 100644
--- a/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
+++ b/drivers/net/wireless/intel/iwlwifi/iwl-drv.c
@@ -832,7 +832,7 @@ static int iwl_parse_tlv_firmware(struct iwl_drv *drv=
,
 			capa->standard_phy_calibration_size =3D
 					le32_to_cpup((__le32 *)tlv_data);
 			break;
-		 case IWL_UCODE_TLV_SEC_RT:
+		case IWL_UCODE_TLV_SEC_RT:
 			iwl_store_ucode_sec(pieces, tlv_data, IWL_UCODE_REGULAR,
 					    tlv_len);
 			drv->fw.type =3D IWL_FW_MVM;
@@ -864,7 +864,7 @@ static int iwl_parse_tlv_firmware(struct iwl_drv *drv=
,
 						FW_PHY_CFG_RX_CHAIN) >>
 						FW_PHY_CFG_RX_CHAIN_POS;
 			break;
-		 case IWL_UCODE_TLV_SECURE_SEC_RT:
+		case IWL_UCODE_TLV_SECURE_SEC_RT:
 			iwl_store_ucode_sec(pieces, tlv_data, IWL_UCODE_REGULAR,
 					    tlv_len);
 			drv->fw.type =3D IWL_FW_MVM;
@@ -1335,7 +1335,8 @@ static void iwl_req_fw_callback(const struct
firmware *ucode_raw, void *context)
  	/* Runtime instructions and 2 copies of data:
 	 * 1) unmodified from disk
-	 * 2) backup cache for save/restore during power-downs */
+	 * 2) backup cache for save/restore during power-downs
+	 */
 	for (i =3D 0; i < IWL_UCODE_TYPE_MAX; i++)
 		if (iwl_alloc_ucode(drv, pieces, i))
 			goto out_free_fw;
--=20
2.13.5



--gRmwerBN0hJlqwNjP1ShQwXtoR00B893K--

--pW4qBsv3Puj2Rn27l1vfQ7lNEcWe0732q
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJZyOpwAAoJEM3PQE6B9NDDxMQP/jAuB2uEtTPsfRuHxOZxvIxD
kEa3vTchvSQqfHfpykiiG9WiVlLoyDAEuwa7rmNT/sCNfIcA7roT8sAPT5w16Hqr
MWYAsq/BzAbnqv3fk2TM5j+fIXgq97/Hw3+aAn8+FLUjCynXdq+I92bL98ABlKj+
3uBgQ2anhbSdE2NCKMYJEa5DRlQxO++GkU20cQ30UCAVKewS/eTjjX4jn8TzjGO5
ZYSZ24dNdoajMy93C6SSPn4MVmSPhksNEfZ9ajATeJ9TbZYgeIJsJ95GlKbICL+S
T0tvEp28jBYK+JBob465uhVxNvHKllpdPKWNnb0PNhrHmQkwyscEf/RX/sc+u27s
Q7bdH/j+3c5L1fNVXi4ISFD+HGGoHYmAE1uI+wpL1z2LrX66Ke1z5B/pmIVdEwqe
Gs3f0TX68dlMGw7D8loq41s0z6UJ4kPMBYbd58rvitB8cYaGDpcPzRH+RqlA3wOq
UT7F2j2LHToqXK/j8Eeuqg8IRHlHeZxj85idOcNk+PIA0d6Rnd652rG8pUyrTAPP
nGAcauvg7wK/1eluV7YWWaTt2eFgmstl2W0IwFjBflKeeMbOdrkGpqKkiY8ttmm7
8UolBWi/ljpIhlqmuDaOw6aJbv5CP8qWczRIfbl8Ges4PlZ8h1j0gF3I712u3YMs
rKlfVlLjG3xDIW3z4C8u
=Wj+n
-----END PGP SIGNATURE-----

--pW4qBsv3Puj2Rn27l1vfQ7lNEcWe0732q--
