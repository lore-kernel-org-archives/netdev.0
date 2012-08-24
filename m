From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-08-24
Date: Fri, 24 Aug 2012 13:31:38 -0400
Message-ID: <20120824173138.GD27147@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IrhDeMKUP4DT/M7F"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58037 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761Ab2HXRt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:49:26 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--IrhDeMKUP4DT/M7F
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit f20b6213f193f455a62ef9299ceca11f5531dff8

Dave,

This is a batch of updates intended for 3.7.  The bulk of it is
mac80211 changes, including some mesh work from Thomas Pederson and
some multi-channel work from Johannes.  A variety of driver updates
and other bits are scattered in there as well.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit e6e94e392fddb8845bdd2e199f55ebf7d76cb58d:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge (=
2012-08-24 11:30:50 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to f20b6213f193f455a62ef9299ceca11f5531dff8:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-08-24 12:25:30 -0400)

----------------------------------------------------------------

AceLan Kao (1):
      Revert "rfkill: remove dead code"

Amit Beka (1):
      iwlwifi: fix FW restart on init FW

Antonio Quartulli (2):
      mac80211: add supported rates change notification in IBSS
      ath9k_htc: implement sta_rc_update() mac80211 callback

Arik Nemtsov (2):
      wlcore: don't get the hlid from a queued skb
      wlcore: op_tx: pass sta explicitly when inferring frame hlid

Christian Lamparter (1):
      carl9170: report A-MPDU status

Chun-Yeow Yeoh (1):
      mac80211: don't re-init rate control when receiving mesh beacon

Eliad Peller (1):
      mac80211: add PS flag to bss_conf

Emmanuel Grumbach (4):
      iwlwifi: s/iwl_ucode_callback/iwl_req_fw_callback
      iwlwifi: get the correct HCMD in the response handler
      mac80211: don't call mgd_prepare_tx when associated
      iwlwifi: fix the preparation of the card

Eyal Shapira (1):
      mac80211: avoid using synchronize_rcu in ieee80211_set_probe_resp

Johannes Berg (38):
      iwlwifi: fix aggregation check indentation
      iwlwifi: reduce max remain-on-channel duration
      mac80211: don't react to beacon loss if HW monitoring
      mac80211: supress HT/VHT disable if not supported
      mac80211: rename sta to new_sta
      mac80211: set channel only once during auth/assoc
      mac80211: use oper_channel in mesh
      mac80211: use oper_channel in ibss
      mac80211: use oper_channel in managed mlme
      mac80211: use oper_channel in utils and config
      mac80211: fix current vs. operating channel in preq/beacon
      mac80211: use correct channel in TX
      mac80211: manage carrier state in mesh
      mac80211: enable WDS carrier only after adding station
      mac80211: use eth_broadcast_addr
      mac80211: reset station MLME flags upon new association
      wireless: add radiotap A-MPDU status field
      mac80211: support A-MPDU status reporting
      mac80211: remove unneeded 'bssid' variable
      mac80211: clean up CSA handling code
      mac80211: fix CSA handling timer
      mac80211: check size of channel switch IE when parsing
      mac80211: make ieee80211_beacon_connection_loss_work static
      cfg80211: add P2P Device abstraction
      mac80211: support P2P Device abstraction
      mac80211: add IEEE80211_HW_P2P_DEV_ADDR_FOR_INTF
      mac80211_hwsim: add support for P2P Device
      mac80211: simplify buffers in aes_128_cmac_vector
      mac80211: mesh: don't use global channel type
      mac80211: remove almost unused local variable
      mac80211: remove freq/chantype from debugfs
      mac80211: use oper_channel in rate init
      mac80211: don't assume channel is set in tracing
      mac80211: use RX status band instead of current band
      mac80211: check operating channel in scan
      mac80211: convert ops checks to WARN_ON
      mac80211: pass channel to ieee80211_send_probe_req
      mac80211: clean up ieee80211_subif_start_xmit

John W. Linville (4):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Mahesh Palivela (1):
      mac80211: VHT (11ac) association

Meenakshi Venkataraman (2):
      iwlwifi: clean up properly when registration with mac80211 fails
      iwlwifi: rework the iwlwifi debugfs structure

Rafa=C5=82 Mi=C5=82ecki (2):
      bcma: detect and register serial flash device
      bcma: detect and register NAND flash device

Sujith Manoharan (1):
      mac80211: Fix AP mode regression

Thomas Huehn (1):
      mac80211: move TX station pointer and restructure TX

Thomas Pedersen (6):
      mac80211: improve cleanup when leaving mesh
      mac80211: remove ieee80211_clean_sdata()
      mac80211: don't request ack for peering close
      mac80211: skb leak in mesh_plink_frame_tx()
      mac80211: use skb_queue_walk() in mesh_path_assign_nexthop
      mac80211: clean up mpath_move_to_queue()

Vladimir Kondratiev (1):
      cfg80211: unify IE search

 drivers/bcma/Kconfig                               |   4 +-
 drivers/bcma/bcma_private.h                        |   2 +
 drivers/bcma/driver_chipcommon_nflash.c            |  28 +-
 drivers/bcma/driver_chipcommon_sflash.c            | 123 ++++++++-
 drivers/bcma/main.c                                |  17 ++
 drivers/net/wireless/adm8211.c                     |   4 +-
 drivers/net/wireless/at76c50x-usb.c                |   4 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   3 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   1 +
 drivers/net/wireless/ath/ath9k/htc.h               |   1 +
 drivers/net/wireless/ath/ath9k/htc_drv_beacon.c    |   2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  35 ++-
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |   2 +-
 drivers/net/wireless/ath/ath9k/main.c              |   5 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |   9 +-
 drivers/net/wireless/ath/carl9170/carl9170.h       |   5 +-
 drivers/net/wireless/ath/carl9170/rx.c             |  15 +-
 drivers/net/wireless/ath/carl9170/tx.c             |  16 +-
 drivers/net/wireless/b43/main.c                    |   3 +-
 drivers/net/wireless/b43legacy/main.c              |   1 +
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   6 +-
 drivers/net/wireless/iwlegacy/3945-mac.c           |  12 +-
 drivers/net/wireless/iwlegacy/4965-mac.c           |  26 +-
 drivers/net/wireless/iwlegacy/4965.h               |   8 +-
 drivers/net/wireless/iwlwifi/dvm/agn.h             |  13 +-
 drivers/net/wireless/iwlwifi/dvm/debugfs.c         |  56 ++--
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   8 +-
 drivers/net/wireless/iwlwifi/dvm/main.c            |  24 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/tx.c              |  18 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             | 141 ++++++++--
 drivers/net/wireless/iwlwifi/iwl-drv.h             |   6 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   3 +-
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  12 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   6 +
 drivers/net/wireless/iwlwifi/pcie/internal.h       |   1 +
 drivers/net/wireless/iwlwifi/pcie/rx.c             |  16 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  28 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |  26 +-
 drivers/net/wireless/libertas_tf/main.c            |   4 +-
 drivers/net/wireless/mac80211_hwsim.c              |   8 +-
 drivers/net/wireless/mwl8k.c                       |  17 +-
 drivers/net/wireless/p54/lmac.h                    |   4 +-
 drivers/net/wireless/p54/main.c                    |   2 +-
 drivers/net/wireless/p54/txrx.c                    |  15 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |   4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   2 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   4 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  20 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |   6 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   6 +-
 drivers/net/wireless/rtlwifi/base.c                |   3 +-
 drivers/net/wireless/rtlwifi/core.c                |   8 +-
 drivers/net/wireless/rtlwifi/pci.c                 |  16 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   5 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.h       |   1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |   5 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.h       |   4 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   5 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.h       |   1 +
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   5 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.h       |   1 +
 drivers/net/wireless/rtlwifi/usb.c                 |  15 +-
 drivers/net/wireless/rtlwifi/wifi.h                |  13 +-
 drivers/net/wireless/ti/wl1251/main.c              |   4 +-
 drivers/net/wireless/ti/wlcore/main.c              |   6 +-
 drivers/net/wireless/ti/wlcore/tx.c                |  61 ++---
 drivers/net/wireless/ti/wlcore/tx.h                |   4 +-
 drivers/net/wireless/zd1211rw/zd_mac.c             |   6 +-
 drivers/staging/winbond/wbusb.c                    |   4 +-
 include/linux/bcma/bcma_driver_chipcommon.h        |  26 ++
 include/linux/bcma/bcma_regs.h                     |   2 +
 include/linux/nl80211.h                            |  30 ++-
 include/linux/rfkill.h                             |  31 +++
 include/net/cfg80211.h                             |  40 ++-
 include/net/ieee80211_radiotap.h                   |  11 +
 include/net/mac80211.h                             |  87 +++++--
 net/mac80211/aes_cmac.c                            |   6 +-
 net/mac80211/cfg.c                                 |  66 +++--
 net/mac80211/debugfs.c                             |  32 ---
 net/mac80211/driver-ops.h                          |  11 +-
 net/mac80211/ibss.c                                |  15 +-
 net/mac80211/ieee80211_i.h                         |  30 ++-
 net/mac80211/iface.c                               | 289 +++++++++++++----=
----
 net/mac80211/main.c                                |  21 +-
 net/mac80211/mesh.c                                |  28 +-
 net/mac80211/mesh.h                                |   3 +
 net/mac80211/mesh_hwmp.c                           |   2 -
 net/mac80211/mesh_pathtbl.c                        |  44 ++--
 net/mac80211/mesh_plink.c                          |  38 ++-
 net/mac80211/mlme.c                                | 240 +++++++++++------
 net/mac80211/offchannel.c                          |   6 +
 net/mac80211/rate.h                                |   2 +-
 net/mac80211/rx.c                                  |  58 ++++-
 net/mac80211/scan.c                                |  12 +-
 net/mac80211/status.c                              |  22 +-
 net/mac80211/trace.h                               |  11 +-
 net/mac80211/tx.c                                  |  71 +++--
 net/mac80211/util.c                                |  57 ++--
 net/rfkill/core.c                                  |  14 +
 net/wireless/chan.c                                |   7 +-
 net/wireless/core.c                                |  53 +++-
 net/wireless/mlme.c                                |  10 +-
 net/wireless/nl80211.c                             | 122 ++++++++-
 net/wireless/radiotap.c                            |   2 +
 net/wireless/util.c                                |  36 +--
 106 files changed, 1765 insertions(+), 721 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--IrhDeMKUP4DT/M7F
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQN7p6AAoJEJctW/TcYTgG2qIQAIzGGRMblu3RQ46dfkx6tuHv
+rPrIrUBr152sk0/6enSJ5R9oI09gL7fgLpqNrThPDfbJiruXp3HzSlhMPohHpXf
bcpEQmQ2wCELmF+pyg0nRiGqAJAtiU4Fy+cB5PaJsmATho5Ddk0Mn55L/F+5MkCg
y9ymOr3BZqYcEyenpP5nN2zCkDmrysfV02Crt79sK7ic4uhz45pA+Pb+syoPlnf/
wfL9laXm3vit81dTibrr0DoPyD26rP9Lm7HQsBsOqRCgu5CzqtUNuJrwWyiNVklf
QSMiA91h+G1/gNZeIZXuxyUisyBRtQkJKfViEPP/D8GeWyns62UvX5vMHLpXKURa
kug362anKMQtU2b025/OKtMaVuON/ZQ2MbC4rdFiudzmhzi3LVlJOK/AgV/6WE1w
25RDljNJLCXEOtd7Vn8VdXFHqHv3PVP163988LaqLGltpBtIbZVJidaOMplyNdXH
X5FBCeFsnH5LXuUjrBlDBFQe6eMENqLLgLVgBSGxLYwrQjlOh41pETewfih0IV5X
zYZ8zOedE99Q7YYEBOA5Re/ZuRnpgXz9lr5IkeDBb/kNY2fxda7CDRP3JxpmsXgY
zCOHNyOA8Z2bJ9yk5ZbqrtEYbsDba+obdnTczm28lXNS8iorE748x3EjcARvCJYa
NfZ363AIl8r26LeGvf98
=INSU
-----END PGP SIGNATURE-----

--IrhDeMKUP4DT/M7F--
