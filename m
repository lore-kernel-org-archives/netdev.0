From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-02-20
Date: Thu, 20 Feb 2014 15:30:05 -0500
Message-ID: <20140220203005.GF3657@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="nFreZHaLTZJo0R7j"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:41706 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbaBTUaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 15:30:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of wireless updates intended for the 3.15
stream!

For the mac80211 bits, Johannes says:

"We have some cleanups and minor fixes as well as userspace API
improvements from a lot of people, extended VHT support for radiotap
=66rom Emmanuel, CSA improvements from Andrei, Luca and Michal. I've also
included my work on hwsim to make dynamic registration of radios
possible."

Along with that, we get the usual round of updates to ath9k,
brcmfmac, mwifiex, wcn36xx, and the ti drivers -- nothing particularly
noteworthy, mostly just random updates and refactoring.

Also included is a pull of the wireless tree, intended to resolve
some potential merge issues.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 010d3c3989706d800ae72253773fa6537cc9f74c:

  bonding: fix bond_arp_rcv() race of curr_active_slave (2014-02-20 13:20:5=
5 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 88daf80dcca19ff995cc263592426f734a9702f3:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-02-20 15:02:02 -0500)

----------------------------------------------------------------

Aaron Durbin (2):
      mwifiex: balance dma map/unmap sizes
      mwifiex: don't leak DMA command skbuffs

Amitkumar Karwar (7):
      mwifiex: change beacon parameter structure
      mwifiex: separate out response buffer parsing code
      mwifiex: separate out next scan command queueing logic
      mwifiex: implement extended scan feature
      mwifiex: update beamforming capability field for HT
      mwifiex: advertise correct beamforming information for VHT
      mwifiex: cleanup in mwifiex_fill_cap_info()

Andrei Otcheretianski (1):
      mac80211_hwsim: add channel switch support

Antonio Quartulli (1):
      cfg80211: fix channel configuration in IBSS join

Ard Biesheuvel (1):
      mac80211: drop unused param 'encrypted' from ccmp_special_blocks()

Arend van Spriel (7):
      brcmfmac: move SDIO specific functions
      brcmfmac: rename sdio_chip.[ch]
      brcmfmac: make chip related functions host interface independent
      brcmfmac: remove TRACE level debug message from brcmf_sdio_bus_sleep()
      brcmfmac: remove unintended error logging
      brcmfmac: get chip core information from the device
      brcmfmac: CR4 takes precedence over CM3 in brcmf_chip_enter_download()

Ariej Marjieh (3):
      iwlwifi: mvm: remove upper limit for error log base pointer
      iwlwifi: 8000: add 11n only SKU of 8000 devices
      iwlwifi: change number of PAPD groups in PHY DB

Arik Nemtsov (7):
      iwlwifi: add very first D0i3 support
      iwlwifi: mvm: add D0i3 ref/unref for scan
      wlcore: cancel Tx watchdog on suspend and rearm on first Tx after
      wlcore: AP: don't start mac80211 PS on non-peer HLIDs
      wlcore: wl18xx: allow CCK rates for AP mode
      wlcore: decrease warning verbosity during recovery
      wlcore: add support for STA CSA with chan contexts

Avinash Patil (17):
      mwifiex: handle AMPDU supported check for AP interface
      mwifiex: make tos_to_tid_inv part of mwifiex_private structure
      mwifiex: move station list functions to common code
      mwifiex: add tdls_mgmt handler support
      mwifiex: parse TDLS action frames during RX
      mwifiex: add cfg80211 tdls_oper handler support
      mwifiex: add cfg80211 add_station handler support
      mwifiex: add cfg80211 change_station handler support
      mwifiex: provision for holding and restoring packets during TDLS setup
      mwifiex: tdls related handling for data packets addressed to TDLS peer
      mwifiex: AMPDU support for TDLS link
      mwifiex: pass ieee80211_vht_cap to mwifiex_fill_vht_cap_tlv
      mwifiex: add VHT support for TDLS
      mwifiex: separate BA params for TDLS link if 11ac is supported
      mwifiex: disable all TDLS link during disconnection
      mwifiex: parse API version from FW
      mwifiex: add key material v2 support

Barak Bercovitz (2):
      wlcore: block read/writes to FW during ELP
      wlcore: don't stop sched_scan on interface removal

Bing Zhao (4):
      mwifiex: make use of IEEE80211_VHT_MCS_NOT_SUPPORTED
      mwifiex: make 11ac mcs rate tables global and const
      mwifiex: improve readability in 11ac mcsmap to maxrate conversion
      mwifiex: remove unsupported code in 11ac

Chun-Yeow Yeoh (1):
      mac80211: fix the increment of mesh precedence value

Daniel Kim (2):
      brcmfmac: enable firmware console logging functionality
      brcmfmac: correct setting of WEP broadcast/unicast keys

David Spinadel (2):
      iwlwifi: mvm: don't stop sched scan in restart
      iwlwifi: mvm: notify scan completed even if no fw_restart

Eliad Peller (24):
      iwlwifi: mvm: add basic bcast filtering implementation
      iwlwifi: mvm: add predefined broadcast filter configuration
      iwlwifi: mvm: add dest ip to bcast filter configuration
      iwlwifi: mvm: add bcast_filtering debugfs entries
      iwlwifi: add D0i3 references boiler plate
      iwlwifi: add enter/exit D0i3 ops
      iwlwifi: mvm: add D0i3 power configurations
      iwlwifi: mvm: configure vifs upon D0i3 entry/exit
      iwlwifi: mvm: allow transport sleep when FW is operational
      iwlwifi: mvm: add D0i3 ref/unref for ROC commands
      iwlwifi: mvm: add D0i3 ref/unref when ap, ibss or p2p_cli vifs are ru=
nning
      iwlwifi: mvm: add d0i3_refs debugfs file
      iwlwifi: mvm: configure WOWLAN_CONFIGURATION on D0i3 entry
      iwlwifi: mvm: get status on D0i3 exit
      iwlwifi: mvm: add debugfs hook to take an mvm ref
      iwlwifi: mvm: reserve sta_id 0 to station
      wlcore/wl12xx/wl18xx: simplify fw_status handling
      wlcore/wl12xx/wl18xx: configure num_links per-hw
      wlcore/wl12xx/wl18xx: configure max_stations per-hw
      wlcore/wl12xx/wl18xx: configure iface_combinations per-hw
      wl18xx: move to new firmware (wl18xx-fw-3.bin)
      wlcore: don't handle unsetting of default wep key
      wlcore: consider multiple APs when checking active_link_count
      wlcore: enable beacon filtering only after receiving a beacon

Emmanuel Grumbach (24):
      iwlwifi: 7000: warn about old firmware
      iwlwifi: remove obsolete TODO
      iwlwifi: mvm: provide helper to fetch the iwl_mvm_sta from sta_id
      iwlwifi: mvm: check ARRAY_SIZE(mvm->fw_id_to_mac_id) =3D IWL_MVM_STAT=
ION_COUNT
      iwlwifi: pcie: fix unused variable gcc warning
      iwlwifi: mvm: BT Coex - set low latency vif as primary
      iwlwifi: mvm: BT Coex - change SMPS settings in AP mode
      iwlwifi: mvm: change the format of the SRAM dump
      iwlwifi: mvm: allow to force reduced tx power from debugfs
      iwlwifi: mvm: add vif type in debugfs output
      iwlwifi: fix kerneldoc format
      iwlwifi: mvm: BT Coex - fix SYNC2SCO flags
      iwlwifi: mvm: remove duplicate assignment to ap_ibss_active
      iwlwifi: mvm: clean up in power code
      iwlwifi: mvm: don't look at power commmand to decide if power is enab=
led
      iwlwifi: mvm: don't send the beacon filtering command from iterator
      iwlwifi: mvm: store latest power command for debugfs read
      iwlwifi: mvm: remove support for legacy power API
      iwlwifi: mvm: remove iwl_mvm_power_mac_disable
      iwlwifi: mvm: refactor power code
      mac80211: remove unused radiotap vendor fields in ieee80211_rx_status
      mac80211: move VHT related RX_FLAG to another variable
      mac80211: propagate STBC / LDPC flags to radiotap
      iwlwifi: mvm: fix typo in WARNING in rs.c

Eran Harary (8):
      iwlwifi: Add 8000 HW family support
      iwlwifi: mvm: support NVM sections for family 8000
      iwlwifi: pcie: disable APMG configurations for family 8000
      iwlwifi: pcie: change CSR reset in family 8000
      iwlwifi: pcie: Disable L0S exit timer for 8000 HW family
      iwlwifi: pcie: fix secure section / dual cpu firmware loading
      iwlwifi: mvm: support multiple firmware sections
      iwlwifi: mvm: support alive notification api version2

Eyal Shapira (1):
      mac80211: advertise BF STS according to AP support

Franky Lin (1):
      brcmfmac: add owner info to sdio_driver structure

Geert Uytterhoeven (1):
      ath9k: Fix uninitialized variable in ath9k_has_tx_pending()

Hante Meuleman (4):
      brcmfmac: expand sta info to report dtim and beacon period.
      brcmfmac: fix sdio sending of large buffers.
      brcmfmac: simplify sdio code download routine.
      brcmfmac: on sdio remove first detach bus then stop worker.

Ido Yariv (3):
      iwlwifi: pcie: retrieve and parse ACPI power limitations
      iwlwifi: mvm: handle platform PCIe power limitation
      iwlwifi: 7265: add power limit/tx backoff translation table

Igal Chernobelsky (1):
      wlcore: send EAPOL frames with voice priority

Ilan Peer (5):
      iwlwifi: mvm: add the quota remainder to a data binding
      iwlwifi: mvm: fix quota allocation
      cfg80211: fix few minor issues in reg_process_hint()
      mac80211: Fix ROC duration =3D=3D 0 handling
      iwlwifi: mvm: modify the tsf_id master/slave logic

Janusz Dziedzic (4):
      nl80211: add Guard Interval support for set_bitrate_mask
      cfg80211: set preset_chandef after channel switch
      cfg80211: add helper reg_get_regdomain() function
      cfg80211: regulatory introduce maximum bandwidth calculation

Johannes Berg (32):
      iwlwifi: mvm: implement AP/GO uAPSD support
      iwlwifi: pcie: make FH debugfs file code easier to understand
      iwlwifi: mvm: add low-latency framework
      iwlwifi: mvm: disable powersave in low-latency
      iwlwifi: mvm: reserve bandwidth for low-latency interface
      iwlwifi: mvm: limit non-low-latency binding scheduling duration
      iwlwifi: rs: use const u16 for throughput tables
      iwlwifi: mvm: remove unneeded calculations
      iwlwifi: mvm: abort scheduled scan on scan request
      iwlwifi: mvm: clean up iwl_mvm_bss_info_changed_ap_ibss
      cfg80211: make connect ie param const
      nl80211: check channel switch validity better
      mac80211: mesh: remove mesh_id check
      mac80211: use sdata mesh_id_len instead of wdev's
      mac80211: fix agg_status debugfs file write
      mac80211: make rate control ops const
      mac80211: make cfg80211 ops and privid const
      nl80211: make netlink attribute policies const
      cfg80211: make device_type const
      mac80211_hwsim: make netlink policy const
      mac80211: minstrel_ht: sample_table can be __read_mostly
      mac80211: remove module handling from rate control ops
      mac80211_hwsim: make P2P-Device support optional
      nl80211: check nla_parse() return values
      mac80211: add length check in ieee80211_is_robust_mgmt_frame()
      nl80211: send event when AP operation is stopped
      nl80211: fix scheduled scan RSSI matchset attribute confusion
      mac80211: remove set but unused variables
      mac80211: fix bufferable MMPDU RX handling
      wireless: sort and extend element ID list
      mac80211: order IEs in probe request correctly
      mac80211: order IEs in association request correctly

John W. Linville (4):
      Merge git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jouni Malinen (3):
      cfg80211: Allow BSS hint to be provided for connect
      cfg80211: Advertise maximum associated STAs in AP mode
      cfg80211: Clean up connect params and channel fetching

Karl Beldan (1):
      mac80211: send {ADD,DEL}BA on AC_VO like other mgmt frames, as per sp=
ec

Liad Kaufman (1):
      iwlwifi: fix potential buffer overrun in fw name

Luciano Coelho (4):
      mac80211: refactor ieee80211_mesh_process_chanswitch()
      mac80211: align ieee80211_mesh_csa_beacon() with ieee80211_assign_bea=
con()
      mac80211: only set CSA beacon when at least one beacon must be transm=
itted
      mac80211: ibss: remove unnecessary call to release channel

Marek Kwaczynski (1):
      mac80211: update opmode when adding new station

Masaki TAGAWA (1):
      ath9k_htc: Add device ID for Buffalo WLI-UV-AG300P

Michal Kazior (7):
      mac80211: batch CSA bss info notification
      mac80211: fix possible memory leak on AP CSA failure
      mac80211: move csa_active setting in STA CSA
      mac80211: fix sdata->radar_required locking
      mac80211: add missing CSA locking
      cfg80211: consider existing DFS interfaces
      ath9k: prepare for multi-interface CSA support

Nadim Zubidat (1):
      wlcore: memset wl->rx_filter_enabled to zero after recovery

Oleksij Rempel (13):
      ath: add last_rssi to ath_common
      ath9k: move ath9k_process_rssi to common.c
      ath9k: move ath9k_process_rate to common.c
      ath9k: move ath9k_rx_accept to common.c
      ath9k_htc: add rx header converter to make it usable by ath9k
      ath9k_htc: use ath9k_cmn_process_rssi
      ath9k_htc: use ath9k_cmn_process_rate
      ath9k_htc: use ath9k_cmn_rx_accept
      ath9k_htc: sync rx_status-> related code with ath9k
      ath9k: move ath9k_rx_skb_postprocess to common.c
      ath9k_htc: use ath9k_cmn_rx_skb_postprocess
      ath9k_htc: remove useless memcpy
      ath9k_htc: catch fw panic pattern

Pontus Fuchs (9):
      wcn36xx: Fix copy paste error hal_exit_bmps -> hal_keep_alive
      wcn36xx: Improve feature caps exchange
      wcn36xx: Wait longer for SMD commands to complete
      wcn36xx: Cache nv to avoid request_firmware on resume path
      wcn36xx: Print FW capabilities
      wcn36xx: Add support for 3680
      wcn36xx: Rename wcn36xx_vif.ucast_dpu_signature to self_ucast_dpu_sign
      wcn36xx: Track dpu signature per sta
      wcn36xx: Update dtim period before starting BSS

Shaibal Dutta (2):
      net: wireless: move regulatory timeout work to power efficient workqu=
eue
      net: rfkill: move poll work to power efficient workqueue

Simon Wunderlich (1):
      mac80211: send ibss probe responses with noack flag

Stanislaw Gruszka (1):
      rt2x00: move frequent messages to debug level

Stephen Rothwell (1):
      Staging: rtl8812ae: remove modules field of rate_control_ops

Sujith Manoharan (9):
      ath9k: Remove unnecessary check
      ath9k: Remove ath9k rate control
      ath9k: Fix IQ cal post processing for SoC
      ath9k: Check explicitly for IQ calibration
      ath9k: Rename ar9003_hw_tx_iqcal_load_avg_2_passes
      ath9k: Fix magnitude/phase calculation
      ath9k: Modify IQ calibration for AR955x
      ath9k: Expand the IQ coefficient array
      ath9k: Calculate IQ-CAL median

Yaniv Machani (1):
      wlcore: increase timeout to 5000 msecs

ZHAO Gang (1):
      b43: use kernel api to replace b43 specific helper function

andrea merello (2):
      mac80211: add check on hw->max_signal value on ieee80211_register_hw
      rtl818x: change misleading names for few register bit definitions

 drivers/net/wireless/ath/ath.h                     |    2 +
 drivers/net/wireless/ath/ath10k/txrx.c             |    4 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |   27 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |   12 -
 drivers/net/wireless/ath/ath9k/Makefile            |    1 -
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |  235 ++-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   11 +-
 drivers/net/wireless/ath/ath9k/beacon.c            |   29 +-
 drivers/net/wireless/ath/ath9k/common.c            |  244 ++++
 drivers/net/wireless/ath/ath9k/common.h            |   19 +
 drivers/net/wireless/ath/ath9k/debug.h             |    1 -
 drivers/net/wireless/ath/ath9k/dfs_debug.h         |    2 +
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    2 +
 drivers/net/wireless/ath/ath9k/htc.h               |    1 -
 drivers/net/wireless/ath/ath9k/htc_drv_init.c      |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_txrx.c      |  176 +--
 drivers/net/wireless/ath/ath9k/htc_hst.c           |   36 +
 drivers/net/wireless/ath/ath9k/htc_hst.h           |   12 +
 drivers/net/wireless/ath/ath9k/hw.c                |    1 -
 drivers/net/wireless/ath/ath9k/init.c              |   16 +-
 drivers/net/wireless/ath/ath9k/mac.h               |    9 +-
 drivers/net/wireless/ath/ath9k/main.c              |   16 +-
 drivers/net/wireless/ath/ath9k/rc.c                | 1495 ----------------=
----
 drivers/net/wireless/ath/ath9k/rc.h                |  248 ----
 drivers/net/wireless/ath/ath9k/recv.c              |  266 +---
 drivers/net/wireless/ath/ath9k/xmit.c              |    2 +-
 drivers/net/wireless/ath/wcn36xx/dxe.c             |   10 +-
 drivers/net/wireless/ath/wcn36xx/dxe.h             |    4 +-
 drivers/net/wireless/ath/wcn36xx/hal.h             |    4 +-
 drivers/net/wireless/ath/wcn36xx/main.c            |   72 +-
 drivers/net/wireless/ath/wcn36xx/smd.c             |   64 +-
 drivers/net/wireless/ath/wcn36xx/smd.h             |    5 +-
 drivers/net/wireless/ath/wcn36xx/txrx.c            |    7 +-
 drivers/net/wireless/ath/wcn36xx/wcn36xx.h         |   10 +-
 drivers/net/wireless/b43/main.h                    |   35 -
 drivers/net/wireless/b43/xmit.c                    |   12 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |    8 +-
 drivers/net/wireless/brcm80211/brcmfmac/chip.c     | 1029 ++++++++++++++
 drivers/net/wireless/brcm80211/brcmfmac/chip.h     |   91 ++
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  536 ++++---
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |    5 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.h     |    2 +-
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |  972 -------------
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.h    |  231 ---
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   89 ++
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |   83 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |    3 +-
 drivers/net/wireless/iwlegacy/3945-rs.c            |    3 +-
 drivers/net/wireless/iwlegacy/4965-rs.c            |    3 +-
 drivers/net/wireless/iwlwifi/Kconfig               |   14 +
 drivers/net/wireless/iwlwifi/Makefile              |    2 +-
 drivers/net/wireless/iwlwifi/dvm/rs.c              |   23 +-
 drivers/net/wireless/iwlwifi/dvm/rs.h              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-7000.c            |   23 +-
 drivers/net/wireless/iwlwifi/iwl-8000.c            |  132 ++
 drivers/net/wireless/iwlwifi/iwl-config.h          |   18 +
 drivers/net/wireless/iwlwifi/iwl-csr.h             |   32 -
 drivers/net/wireless/iwlwifi/iwl-debug.h           |    2 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    5 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    7 +-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   15 +
 drivers/net/wireless/iwlwifi/iwl-io.h              |    2 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |    6 +-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   24 +-
 drivers/net/wireless/iwlwifi/iwl-phy-db.c          |    4 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   46 +
 drivers/net/wireless/iwlwifi/iwl-trans.h           |   38 +
 drivers/net/wireless/iwlwifi/mvm/Makefile          |    2 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |  138 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |    4 +
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   31 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs-vif.c     |  112 +-
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  285 +++-
 drivers/net/wireless/iwlwifi/mvm/fw-api-bt-coex.h  |   17 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-d3.h       |    6 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |   33 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |   31 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |  128 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   67 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   76 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  476 ++++++-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  168 ++-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |   34 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  257 +++-
 drivers/net/wireless/iwlwifi/mvm/power.c           |  385 +++--
 drivers/net/wireless/iwlwifi/mvm/power_legacy.c    |  319 -----
 drivers/net/wireless/iwlwifi/mvm/quota.c           |  119 +-
 drivers/net/wireless/iwlwifi/mvm/rs.c              |   29 +-
 drivers/net/wireless/iwlwifi/mvm/rs.h              |    2 +-
 drivers/net/wireless/iwlwifi/mvm/rx.c              |   12 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |   15 +-
 drivers/net/wireless/iwlwifi/mvm/sta.c             |  203 ++-
 drivers/net/wireless/iwlwifi/mvm/sta.h             |   62 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |    2 +
 drivers/net/wireless/iwlwifi/mvm/tt.c              |    7 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   23 +
 drivers/net/wireless/iwlwifi/mvm/utils.c           |   99 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   82 ++
 drivers/net/wireless/iwlwifi/pcie/rx.c             |    3 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  267 ++--
 drivers/net/wireless/iwlwifi/pcie/tx.c             |    5 +-
 drivers/net/wireless/libertas/cfg.c                |    3 +-
 drivers/net/wireless/mac80211_hwsim.c              |   90 +-
 drivers/net/wireless/mac80211_hwsim.h              |    2 +
 drivers/net/wireless/mwifiex/11ac.c                |  192 ++-
 drivers/net/wireless/mwifiex/11ac.h                |    2 +
 drivers/net/wireless/mwifiex/11n.c                 |   51 +-
 drivers/net/wireless/mwifiex/11n.h                 |   44 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   27 +-
 drivers/net/wireless/mwifiex/Makefile              |    1 +
 drivers/net/wireless/mwifiex/cfg80211.c            |  184 ++-
 drivers/net/wireless/mwifiex/cfp.c                 |  203 ++-
 drivers/net/wireless/mwifiex/cmdevt.c              |   54 +-
 drivers/net/wireless/mwifiex/decl.h                |   23 +
 drivers/net/wireless/mwifiex/fw.h                  |  181 ++-
 drivers/net/wireless/mwifiex/init.c                |    5 +
 drivers/net/wireless/mwifiex/ioctl.h               |   22 +-
 drivers/net/wireless/mwifiex/join.c                |   14 +-
 drivers/net/wireless/mwifiex/main.h                |   90 +-
 drivers/net/wireless/mwifiex/pcie.c                |  138 +-
 drivers/net/wireless/mwifiex/scan.c                |  598 +++++---
 drivers/net/wireless/mwifiex/sta_cmd.c             |  373 ++++-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |  112 +-
 drivers/net/wireless/mwifiex/sta_event.c           |   12 +
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   40 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |   13 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |    3 +
 drivers/net/wireless/mwifiex/tdls.c                | 1044 ++++++++++++++
 drivers/net/wireless/mwifiex/uap_event.c           |  118 --
 drivers/net/wireless/mwifiex/util.c                |  114 ++
 drivers/net/wireless/mwifiex/util.h                |   20 +-
 drivers/net/wireless/mwifiex/wmm.c                 |   96 +-
 drivers/net/wireless/mwifiex/wmm.h                 |   18 +
 drivers/net/wireless/rndis_wlan.c                  |    4 +-
 drivers/net/wireless/rt2x00/rt2800usb.c            |   10 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |    8 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |   14 +-
 drivers/net/wireless/rtl818x/rtl818x.h             |   10 +-
 drivers/net/wireless/rtlwifi/rc.c                  |    3 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |    2 +-
 drivers/net/wireless/ti/wl12xx/main.c              |   67 +-
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |   53 +
 drivers/net/wireless/ti/wl18xx/main.c              |   85 +-
 drivers/net/wireless/ti/wl18xx/tx.c                |    4 +-
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |   62 +-
 drivers/net/wireless/ti/wlcore/acx.c               |    7 +-
 drivers/net/wireless/ti/wlcore/acx.h               |    6 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   24 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |    9 +-
 drivers/net/wireless/ti/wlcore/event.c             |    4 +-
 drivers/net/wireless/ti/wlcore/hw_ops.h            |    9 +
 drivers/net/wireless/ti/wlcore/init.c              |    6 +-
 drivers/net/wireless/ti/wlcore/io.h                |    8 +-
 drivers/net/wireless/ti/wlcore/main.c              |  192 +--
 drivers/net/wireless/ti/wlcore/ps.c                |    6 +-
 drivers/net/wireless/ti/wlcore/rx.c                |   19 +-
 drivers/net/wireless/ti/wlcore/rx.h                |    2 +-
 drivers/net/wireless/ti/wlcore/tx.c                |   45 +-
 drivers/net/wireless/ti/wlcore/tx.h                |    1 +
 drivers/net/wireless/ti/wlcore/wlcore.h            |   27 +-
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   86 +-
 drivers/staging/rtl8821ae/rc.c                     |    1 -
 include/linux/ieee80211.h                          |  199 ++-
 include/net/cfg80211.h                             |   43 +-
 include/net/ieee80211_radiotap.h                   |    4 +
 include/net/mac80211.h                             |   52 +-
 include/uapi/linux/nl80211.h                       |   52 +-
 net/mac80211/agg-tx.c                              |    2 +-
 net/mac80211/cfg.c                                 |  198 ++-
 net/mac80211/cfg.h                                 |    2 +-
 net/mac80211/chan.c                                |    2 +
 net/mac80211/debugfs_sta.c                         |    2 +-
 net/mac80211/ht.c                                  |    2 +-
 net/mac80211/ibss.c                                |   28 +-
 net/mac80211/ieee80211_i.h                         |   14 +-
 net/mac80211/iface.c                               |    2 +
 net/mac80211/main.c                                |    9 +-
 net/mac80211/mesh.c                                |   96 +-
 net/mac80211/mlme.c                                |   41 +-
 net/mac80211/rate.c                                |   46 +-
 net/mac80211/rate.h                                |    2 +-
 net/mac80211/rc80211_minstrel.c                    |    2 +-
 net/mac80211/rc80211_minstrel.h                    |    2 +-
 net/mac80211/rc80211_minstrel_ht.c                 |    7 +-
 net/mac80211/rc80211_pid_algo.c                    |    2 +-
 net/mac80211/rx.c                                  |  101 +-
 net/mac80211/sta_info.h                            |    2 +
 net/mac80211/status.c                              |    3 +-
 net/mac80211/tx.c                                  |   33 +-
 net/mac80211/util.c                                |   42 +-
 net/mac80211/vht.c                                 |   26 +-
 net/mac80211/wpa.c                                 |    9 +-
 net/rfkill/core.c                                  |    9 +-
 net/wireless/ap.c                                  |    3 +-
 net/wireless/chan.c                                |   23 +-
 net/wireless/core.c                                |    2 +-
 net/wireless/core.h                                |    7 +-
 net/wireless/ibss.c                                |   19 +-
 net/wireless/mesh.c                                |    6 +-
 net/wireless/mlme.c                                |    2 +-
 net/wireless/nl80211.c                             |  229 ++-
 net/wireless/nl80211.h                             |    2 +
 net/wireless/reg.c                                 |  188 ++-
 net/wireless/reg.h                                 |    2 +
 net/wireless/trace.h                               |   23 +-
 net/wireless/util.c                                |    5 +-
 211 files changed, 9921 insertions(+), 6336 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/ath9k/rc.c
 delete mode 100644 drivers/net/wireless/ath/ath9k/rc.h
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/chip.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/chip.h
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.c
 delete mode 100644 drivers/net/wireless/brcm80211/brcmfmac/sdio_chip.h
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-8000.c
 delete mode 100644 drivers/net/wireless/iwlwifi/mvm/power_legacy.c
 create mode 100644 drivers/net/wireless/mwifiex/tdls.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--nFreZHaLTZJo0R7j
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTBmXNAAoJEJctW/TcYTgGukAP/imiWkDoYCtH8pRRsqfUtupz
ImijfboPVuooFS7HLum6dnSxqk2cuOBwTBm3L4m4Bd6hGBob2RVmK/5ZWdXXGsHg
ARGQvSioPtnoOLzWdqGQ/8GZTPrk4cKayvOkxbdpVEqe9AOaLF4ThKSrw2R4o6vi
Wh0iYcGHmW4yL52Kpu5RAL6LJ5SOswT0o9SasYwwBDiceG3EzcM7TLqhRi96KxAc
5Ta32BxWMYaAlcoB86j863BVoMQuzibczW/7Wu1nCUTsE1Suthct1CXGD+T2xTzc
Sbaf89ZGR1ILc6VDfQWpb7cDXhEjZxexAv7gZ3voScVPJ0LIISS7og6CGoG71U9U
6PWTRM3phvHINb3lXV2HayV/wpTlortspVXpqaBZKBPnyDoQwjZNaMHVJVMf4BQx
gJidE4gx0MTtJX5Vok3Czt6V7kzPJg77Bm4ObjS3Da5da9CDwqewgxlghVa3u/Bo
wfhpSBtWMtMNfuq2j6m/Mmp1Sjail1xTM2Y4I43UMKH0i6gCKp8yjk8+BoRLKz/z
k/NRHzPySvOQy5jSlWe4nDqHp6UsGCweWbMQHRXR++QFuE7sjxYh4SSqWmWlJHya
tnTRrGDDHL0lSV/16qIDZLpgimXbOQcL5b4ObakYW+t4SZY+hd36JyBG5oKR/25O
nfKHMh7emxftOWI/yMdq
=noui
-----END PGP SIGNATURE-----

--nFreZHaLTZJo0R7j--
