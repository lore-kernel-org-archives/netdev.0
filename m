From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2014-01-09
Date: Thu, 9 Jan 2014 10:33:17 -0500
Message-ID: <20140109153317.GA2131@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="9amGYk9869ThD9tj"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--9amGYk9869ThD9tj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

I know that this is late in the process.  But, Linus did say he was
doing an -rc8 no matter what!

For the mac80211 bits, Johannes says:

"I have a fix from Javier for mac80211_hwsim when used with wmediumd
userspace, and a fix from Felix for buffering in AP mode."

For the NFC bits, Samuel says:

"This pull request only contains one fix for a regression introduced with
commit e29a9e2ae165620d. Without this fix, we can not establish a p2p link
in target mode. Only initiator mode works."

For the iwlwifi bits, Emmanuel says:

"It only includes new device IDs so it's not vital. If you have a pull
request to net.git anyway, I'd happy to have this in."

Please let me know if there are problems!  If you don't want to pull
this one for 3.13 then I'll just roll it into the wireless-next tree...

John

---

The following changes since commit 732256b9335f8456623bb772d86c2a24e3cafca2:

  tipc: correctly unlink packets from deferred packet queue (2014-01-07 16:=
15:24 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to 0f74d82d80e653545f4190c96a25f3b6751a8370:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-01-09 10:19:01 -0500)

----------------------------------------------------------------

Arron Wang (1):
      NFC: Fix target mode p2p link establishment

Felix Fietkau (1):
      mac80211: move "bufferable MMPDU" check to fix AP mode scan

Javier Lopez (1):
      mac80211_hwsim: Fix NULL pointer dereference

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge tag 'nfc-fixes-3.13-1' of git://git.kernel.org/.../sameo/nfc-fi=
xes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Oren Givon (1):
      iwlwifi: add new devices for 7265 series

 drivers/net/wireless/iwlwifi/pcie/drv.c | 10 ++++++++--
 drivers/net/wireless/mac80211_hwsim.c   |  2 +-
 net/mac80211/tx.c                       | 23 +++++++++++++----------
 net/nfc/core.c                          |  2 +-
 4 files changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index 86605027c41d..e6272546395a 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -357,21 +357,27 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 	{IWL_PCI_DEVICE(0x095B, 0x5310, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5302, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5210, iwl7265_2ac_cfg)},
-	{IWL_PCI_DEVICE(0x095B, 0x5012, iwl7265_2ac_cfg)},
-	{IWL_PCI_DEVICE(0x095B, 0x500A, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5012, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x500A, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5410, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5400, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x1010, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5000, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5200, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5002, iwl7265_n_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5202, iwl7265_n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9010, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9110, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9210, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9510, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x9310, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9410, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5020, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x502A, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5420, iwl7265_2n_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5090, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5190, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5590, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095B, 0x5290, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5490, iwl7265_2ac_cfg)},
 #endif /* CONFIG_IWLMVM */
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/m=
ac80211_hwsim.c
index c72438bb2faf..a1b32ee9594a 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -2011,7 +2011,7 @@ static int hwsim_tx_info_frame_received_nl(struct sk_=
buff *skb_2,
 	   (hwsim_flags & HWSIM_TX_STAT_ACK)) {
 		if (skb->len >=3D 16) {
 			hdr =3D (struct ieee80211_hdr *) skb->data;
-			mac80211_hwsim_monitor_ack(txi->rate_driver_data[0],
+			mac80211_hwsim_monitor_ack(data2->channel,
 						   hdr->addr2);
 		}
 		txi->flags |=3D IEEE80211_TX_STAT_ACK;
diff --git a/net/mac80211/tx.c b/net/mac80211/tx.c
index c558b246ef00..ca7fa7f0613d 100644
--- a/net/mac80211/tx.c
+++ b/net/mac80211/tx.c
@@ -463,7 +463,6 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data =
*tx)
 {
 	struct sta_info *sta =3D tx->sta;
 	struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(tx->skb);
-	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *)tx->skb->data;
 	struct ieee80211_local *local =3D tx->local;
=20
 	if (unlikely(!sta))
@@ -474,15 +473,6 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data=
 *tx)
 		     !(info->flags & IEEE80211_TX_CTL_NO_PS_BUFFER))) {
 		int ac =3D skb_get_queue_mapping(tx->skb);
=20
-		/* only deauth, disassoc and action are bufferable MMPDUs */
-		if (ieee80211_is_mgmt(hdr->frame_control) &&
-		    !ieee80211_is_deauth(hdr->frame_control) &&
-		    !ieee80211_is_disassoc(hdr->frame_control) &&
-		    !ieee80211_is_action(hdr->frame_control)) {
-			info->flags |=3D IEEE80211_TX_CTL_NO_PS_BUFFER;
-			return TX_CONTINUE;
-		}
-
 		ps_dbg(sta->sdata, "STA %pM aid %d: PS buffer for AC %d\n",
 		       sta->sta.addr, sta->sta.aid, ac);
 		if (tx->local->total_ps_buffered >=3D TOTAL_MAX_TX_BUFFER)
@@ -525,9 +515,22 @@ ieee80211_tx_h_unicast_ps_buf(struct ieee80211_tx_data=
 *tx)
 static ieee80211_tx_result debug_noinline
 ieee80211_tx_h_ps_buf(struct ieee80211_tx_data *tx)
 {
+	struct ieee80211_tx_info *info =3D IEEE80211_SKB_CB(tx->skb);
+	struct ieee80211_hdr *hdr =3D (struct ieee80211_hdr *)tx->skb->data;
+
 	if (unlikely(tx->flags & IEEE80211_TX_PS_BUFFERED))
 		return TX_CONTINUE;
=20
+	/* only deauth, disassoc and action are bufferable MMPDUs */
+	if (ieee80211_is_mgmt(hdr->frame_control) &&
+	    !ieee80211_is_deauth(hdr->frame_control) &&
+	    !ieee80211_is_disassoc(hdr->frame_control) &&
+	    !ieee80211_is_action(hdr->frame_control)) {
+		if (tx->flags & IEEE80211_TX_UNICAST)
+			info->flags |=3D IEEE80211_TX_CTL_NO_PS_BUFFER;
+		return TX_CONTINUE;
+	}
+
 	if (tx->flags & IEEE80211_TX_UNICAST)
 		return ieee80211_tx_h_unicast_ps_buf(tx);
 	else
diff --git a/net/nfc/core.c b/net/nfc/core.c
index 872529105abc..83b9927e7d19 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -384,7 +384,7 @@ int nfc_dep_link_is_up(struct nfc_dev *dev, u32 target_=
idx,
 {
 	dev->dep_link_up =3D true;
=20
-	if (!dev->active_target) {
+	if (!dev->active_target && rf_mode =3D=3D NFC_RF_INITIATOR) {
 		struct nfc_target *target;
=20
 		target =3D nfc_find_target(dev, target_idx);
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--9amGYk9869ThD9tj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJSzsE9AAoJEJctW/TcYTgG89sP/13SIm6yYnw1mT1OvPEi070M
3ByaVxUTfEr6kaNX/7aCfhtvWGgAs6klEbTaJBaC/+5mB3R2977miiTwvN3f8FES
pLSkaJwWjA9sYmX7iz1M7f34qaSRFB8IcgKzU9xSTEa9S66hDzEJ9ZKl8RzTXpOa
vKwy0Er0hJgz9m9aKzbdkCspXqyrXNS3ZsFS7n0UqD509eQeQY+fYbokRaBlkEUc
BHpTuBsM4TkidYGcvvr5kYbx/ggcYEVPvNEmEac2prTvaUP1l7DfshPWq/zZoi47
vDRghVgBT86e8dCa34DL6GOqUoczW9SZYRVMB9CcdhP/XcN1a4soZ0HmocjJIx+U
v+m1UUHj/PZO/G4PLoRNNEe/ucad2+LbnDbMTibhHjJOsnLmlqytBazBHNwzMs1G
F+8g6fpUNW6UDX7Bpni7rKFEH4q/itHQPBBBidh3UNmIZmn0+gQGnsS83vSFf7PQ
mKVZmIcqy/zJw7D3IE++LcNGJDOYTB7Zbc3CzQ7JMC4NSosLqC5kXH8X2aqL+p3J
BBoZ2vyF0RvZLnLIpOJvZ4AKQu8qnspQzGTwZfRp+g3EpgflETxxe0+NVPauyupG
Fy6TqVUGUdOLGRZoM+LrcQYeUUZd8SiFlhTZ5ucXv/b/LeYVhrT72UIw2Ddyiabn
hIttQN/HGKZMUBpSmkoT
=UjkG
-----END PGP SIGNATURE-----

--9amGYk9869ThD9tj--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
