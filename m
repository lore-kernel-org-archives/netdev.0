From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Re: pull request: wireless-next 2011-10-11
Date: Tue, 11 Oct 2011 15:38:06 -0400
Message-ID: <20111011193806.GI6558@tuxdriver.com>
References: <20111011191616.GF6558@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7iMSBzlTiPOCCT2k"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111011191616.GF6558-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--7iMSBzlTiPOCCT2k
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Oct 11, 2011 at 03:16:16PM -0400, John W. Linville wrote:
> commit bfb3780bc9b622422c1f0d3e12371a70863000da
>=20
> Dave,
>=20
> Here is another wireless batch intended for 3.2...  Highlights include a
> bluetooth pull with some refactoring, a big pull of ath6kl updates, a
> flurry of mac80211 patches from Johannes, and the usual strong ath9k
> showing.
>=20
> Please let me know if there are problems!

There was a problem -- a warning in ath6kl.  Sorry about that!

commit 094daf7db7c47861009899ce23f9177d761e20b0

Dave,

Here is another wireless batch intended for 3.2...  Highlights include a
bluetooth pull with some refactoring, a big pull of ath6kl updates, a
flurry of mac80211 patches from Johannes, and the usual strong ath9k
showing.

Please let me know if there are problems!

Thanks,

John

P.S.  This version correct a warning due to some merge damage in
ath6kl...

---

The following changes since commit 3ed6f6958c0ac21958285d8648f14d34da4bbcb3:

  ll_temac: convert to SKB paged frag API. (2011-10-10 15:19:13 -0400)

are available in the git repository at:
  git://git.infradead.org/users/linville/wireless-next.git for-davem

Amitkumar Karwar (5):
      mwifiex: remove unnecessary mwifiex_dump_station_info() call
      mwifiex: remove unreachable code
      mwifiex: fix Tx data rate display issue
      mwifiex: correct AMSDU aggregation check
      mwifiex: handle an error path correctly

Anderson Lizardo (1):
      Bluetooth: use recommended LE connection parameters

Andre Guedes (1):
      Bluetooth: hci_le_adv_report_evt code refactoring

Andy Shevchenko (1):
      wireless: at76c50x: use native hex_pack_byte() method

Arik Nemtsov (5):
      nl80211: support sending TDLS commands/frames
      mac80211: standardize adding supported rates IEs
      mac80211: handle TDLS high-level commands and frames
      nl80211/mac80211: allow adding TDLS peers as stations
      mac80211: data path modification for TDLS peers

Daniel Drake (1):
      libertas: detect TX lockups and reset hardware

Don Fry (1):
      iwlagn: rename iwlagn module iwlwifi and alias to iwlagn.

Edward Lu (4):
      ath6kl: Support channel set request for startscan command
      ath6kl: Fix a typo in ath6k context
      ath6kl: Fix default key installation in AP mode
      ath6kl: Do not clear CONNECT bit setting in AP mode for STA disconnect

Eliad Peller (1):
      mac80211: pass vif param to conf_tx() callback

Greg Dietsche (1):
      iwlagn: iwl-agn-rs: remove unnecessary null check for sta and lq_sta

Helmut Schaa (1):
      mac80211: Allow noack flag overwrite for injected frames

Johannes Berg (17):
      cfg80211/mac80211: apply station uAPSD parameters selectively
      mac80211: let drivers inform it about per TID buffered frames
      mac80211: unify TIM bit handling
      mac80211: also expire filtered frames
      mac80211: split PS buffers into ACs
      mac80211: remove return value from add_pending_skbs
      mac80211: clear more-data bit on filtered frames
      mac80211: allow releasing driver-buffered frames
      mac80211: implement uAPSD
      mac80211: send (QoS) Null if no buffered frames
      mac80211: reply only once to each PS-poll
      mac80211: optimise station flags
      mac80211: add missing station flags to debugfs
      mac80211: explicitly notify drivers of frame release
      mac80211: allow out-of-band EOSP notification
      mac80211: document client powersave
      mac80211: dont assign seqno to or aggregate QoS Null frames

John W. Linville (3):
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'master' of git://github.com/padovan/bluetooth-next
      Merge branch 'master' of git://git.infradead.org/users/linville/wirel=
ess-next into for-davem

Jouni Malinen (37):
      ath6kl: Use cfg80211_inform_bss instead of cfg80211_inform_bss_frame
      ath6kl: Add functionality for starting AP mode
      ath6kl: Fix AP mode (Re)AssocReq IE processing
      ath6kl: Delay initial group key setup in AP mode
      ath6kl: Use change_station() to authorize/unauthorize STAs
      ath6kl: Add new WMI commands and events for P2P
      ath6kl: Implement remain_on_channel and cancel_remain_on_channel
      ath6kl: Implement mgmt_tx
      ath6kl: Request P2P capabilities during target init
      ath6kl: Add cfg80211 calls for remain-on-channel events
      ath6kl: Use set_appie command to add Probe Request IEs
      ath6kl: Report received Probe Request frames to cfg80211
      ath6kl: Notify cfg80211 of TX status of mgmt_tx frames
      ath6kl: Report received Action frames to cfg80211
      ath6kl: Advertise supported mgmt_stypes
      ath6kl: Add support for new P2P iftypes in mode changes
      ath6kl: Include P2P IE(s) in GO Probe Response depending on request
      ath6kl: Return error from wmi.c instead of -EIO in ath6kl_cfg80211_sc=
an
      ath6kl: Define __CHECK_ENDIAN__ for sparse
      ath6kl: Do not enable Probe Request reporting by default
      athk6l: Fix channel list processing in scan requests
      ath6kl: Fix WMI message structure for AP_SET_PVB
      ath6kl: Fix AP mode connect event parsing and TIM updates
      ath6kl: Allow AP mode to be configured
      ath6kl: Allow enabling of P2P support
      ath6kl: Fix static WEP configuration in AP mode
      ath6kl: Fix BSS update on roaming
      ath6kl: Remove deprecated WMI_OPT_RX_FRAME_EVENTID processing
      ath6kl: Remove RSSI update for internal node table
      ath6kl: Remove unnecessary node table update on disconnect event
      ath6kl: Replace internal node table with cfg80211 BSS table
      ath6kl: Remove the unused node table implementation
      ath6kl: Remove unnecessary bssinfo event header conversion
      ath6kl: Update BSS information after connection
      ath6kl: Export beacon interval and DTIM period through STA info
      ath6kl: Report PMKSA candidate events through cfg80211
      ath6kl: fix TCP corruption

Kalle Valo (28):
      ath6kl: fix indentation in htc_issued_send()
      ath6kl: implement suspend support
      ath6kl: add testmode support
      ath6kl: fix compilation when NL80211_TESTMODE is disabled
      ath6kl: add firmware log support
      ath6kl: implement support to set firmware log parameters
      ath6kl: cleanup diagnose window read and write functions
      ath6kl: read fwlog from firmware ring buffer
      ath6kl: unify tx function names in htc.c
      ath6kl: unify rx function naming in htc.c
      ath6kl: separate firmware fetch from upload
      ath6kl: fix busy loop in ath6kl_bmi_get_rx_lkahd()
      ath6kl: add support for firmware API 2 format
      ath6kl: refactor firmware load address code
      ath6kl: refactor firmware ext data addr and reserved ram handling size
      ath6kl: read firmware start address from hardware
      ath6kl: read reserved ram size from firmware file
      ath6kl: add firmware capabilities support
      Merge remote branch 'wireless-next/master' into ath6kl-next
      ath6kl: pass only unicast frames for aggregation
      ath6kl: allow firmware to override firmware patch address
      ath6kl: silence "invalid rate" warning
      ath6kl: add prefix parameter to ath6kl_dbg_dump()
      ath6kl: add sdio debug messages
      ath6kl: add debug logs for booting
      ath6kl: improve wmi debug messages
      ath6kl: fix size_t related warnings
      ath6kl: include vmalloc.h in debug.c

Kevin Fang (1):
      ath6kl: Add beginning of AR6004 initialisation support

Larry Finger (2):
      rtlwifi: Remove unused routine _usb_readN_sync
      rtlwifi: Remove unused _usb_nbytes_read_write and _usb_writeN_sync

Lorenzo Bianconi (1):
      mac80211: max_tp_rate2 management of minstrel_ht

Luis R. Rodriguez (1):
      ath9k_htc: add AVM FRITZ!WLAN 11N v2 support

Mat Martineau (3):
      Bluetooth: Linearize skbs for use in BNEP, CMTP, HIDP, and RFCOMM
      Bluetooth: Handle fragmented skbs in bt_sock_stream_recvmsg()
      Bluetooth: Perform L2CAP SDU reassembly without copying data

Mohammed Shafi Shajakhan (4):
      ath9k/ath9k_htc: Fix PS wrappers for RF kill
      ath9k_hw: extend GPIO pin select mask for rfkill
      ath9k_hw: Fix number of GPIO pins for AR9287/9300
      ath9k_hw: set pci_express capability true for AR9480

Oliver Neukum (1):
      btusb: add device entry for Broadcom SoftSailing

Peter Hurley (1):
      Bluetooth: Allow ACL packets over USB in HCI_RAW mode

Raja Mani (2):
      ath6kl: Avoid finding bss presence in cfg80211 scan list
      ath6kl: Check sme state before delivering disconnect event to cfg80211

Rajkumar Manoharan (4):
      ath6kl: Fix compilation error while compiling w/o debug
      ath9k: Remove unnecessary AMPDU check at tx status
      ath9k: Remove redundant my beacon check at ath_rx_ps_beacon
      mac80211: Send nullfunc frames at lower rate during connection monitor

Sam Leffler (1):
      ath6kl: query device tree for firmware board-id

Sangwook Lee (1):
      net:rfkill: add a gpio setup function into GPIO rfkill

Stephen Rothwell (1):
      wireless/ath6kl: use of module_param requires the inclusion of module=
param.h

Szymon Janc (1):
      Bluetooth: Mark not declared l2cap_core functions as static

Vasanthakumar Thiagarajan (21):
      ath6kl: Release ar->lock right afer updating net_stats in ath6kl_rx()
      ath6kl: Minor cleanup in min_hdr_len computation
      ath6kl: Cleanup ath6kl_wmi_data_hdr_remove()
      ath6kl: Fix bug in computing AMSU subframe padding
      ath6kl: Fix buffer alignment for scatter-gather I/O
      ath6kl: Fix system freeze under heavy data load
      ath6kl: Remove unused meta_v2 from ath6kl_data_tx()
      ath6kl: Add wmi meta data information only it is available
      ath6kl: Avoid rolling back of entire scatter setup in case of failure
      ath6kl: Add initial debugfs changes
      ath6kl: Add debugfs entry to dump target stats
      ath6kl: Add debugfs file entry to dump credit distribution stats
      ath6kl: Add debugfs interface to dump diagnostic registers from firmw=
are
      ath6kl: Fix endianness in requesting chip register read
      ath6kl: Make ath6kl_diag_write32() non-static
      ath6kl: Fix endianness in register write
      ath6kl: Add debugfs support to write a chip register
      ath6kl: Remove auth type fall back in auto authentication mode
      ath6kl: Set the sme_state to disconnected in disconnect() callback
      ath6kl: Fix disconnect event reporting
      ath6kl: Remove unnecessary retrieval of first list entry in ath6kl_ht=
c_tx_setup_scat_list()

Vivek Natarajan (4):
      ath6kl: Add debugfs entry to modify roaming parameters.
      ath6kl: Process regulatory requests from firmware.
      ath6kl: deinitialise wiphy on error
      ath6kl: Indicate the roaming capability of the firmware

Waldemar Rymarkiewicz (1):
      Bluetooth: Fix possible NULL pointer dereference

Yogesh Ashok Powar (1):
      mwifiex: add cfg80211 handlers add/del_virtual_intf

 Documentation/DocBook/80211.tmpl                 |   11 +-
 Documentation/feature-removal-schedule.txt       |    9 +
 drivers/bluetooth/btusb.c                        |    6 +-
 drivers/net/wireless/Makefile                    |    2 +-
 drivers/net/wireless/at76c50x-usb.c              |   18 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c    |    2 +-
 drivers/net/wireless/ath/ath6kl/Makefile         |    4 +-
 drivers/net/wireless/ath/ath6kl/bmi.c            |   23 +-
 drivers/net/wireless/ath/ath6kl/bmi.h            |    4 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c       |  894 ++++++++++++-----
 drivers/net/wireless/ath/ath6kl/common.h         |   83 --
 drivers/net/wireless/ath/ath6kl/core.h           |  145 +++-
 drivers/net/wireless/ath/ath6kl/debug.c          |  784 +++++++++++++++
 drivers/net/wireless/ath/ath6kl/debug.h          |   49 +-
 drivers/net/wireless/ath/ath6kl/hif-ops.h        |    5 +
 drivers/net/wireless/ath/ath6kl/hif.h            |    1 +
 drivers/net/wireless/ath/ath6kl/htc.c            |  271 +++---
 drivers/net/wireless/ath/ath6kl/init.c           |  794 ++++++++++++----
 drivers/net/wireless/ath/ath6kl/main.c           |  448 ++++++---
 drivers/net/wireless/ath/ath6kl/node.c           |  234 -----
 drivers/net/wireless/ath/ath6kl/sdio.c           |   79 ++-
 drivers/net/wireless/ath/ath6kl/target.h         |   41 +-
 drivers/net/wireless/ath/ath6kl/testmode.c       |  167 ++++
 drivers/net/wireless/ath/ath6kl/testmode.h       |   36 +
 drivers/net/wireless/ath/ath6kl/txrx.c           |   61 +-
 drivers/net/wireless/ath/ath6kl/wmi.c            | 1126 +++++++++++++++---=
----
 drivers/net/wireless/ath/ath6kl/wmi.h            |  350 ++++++-
 drivers/net/wireless/ath/ath9k/ath9k.h           |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom.h          |    7 +-
 drivers/net/wireless/ath/ath9k/gpio.c            |    7 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c         |    1 +
 drivers/net/wireless/ath/ath9k/htc_drv_gpio.c    |   10 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c    |    3 +-
 drivers/net/wireless/ath/ath9k/hw.c              |   11 +-
 drivers/net/wireless/ath/ath9k/main.c            |    6 +-
 drivers/net/wireless/ath/ath9k/rc.c              |    6 -
 drivers/net/wireless/ath/ath9k/recv.c            |   23 +-
 drivers/net/wireless/ath/ath9k/xmit.c            |   19 +-
 drivers/net/wireless/ath/carl9170/main.c         |    3 +-
 drivers/net/wireless/b43/main.c                  |    3 +-
 drivers/net/wireless/b43legacy/main.c            |    3 +-
 drivers/net/wireless/iwlegacy/iwl-4965-tx.c      |    2 +-
 drivers/net/wireless/iwlegacy/iwl-core.c         |    3 +-
 drivers/net/wireless/iwlegacy/iwl-core.h         |    3 +-
 drivers/net/wireless/iwlwifi/Kconfig             |   22 +-
 drivers/net/wireless/iwlwifi/Makefile            |   40 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c        |    3 -
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c           |    1 +
 drivers/net/wireless/iwlwifi/iwl-core.c          |    5 +-
 drivers/net/wireless/iwlwifi/iwl-core.h          |    3 +-
 drivers/net/wireless/iwlwifi/iwl-shared.h        |    2 +-
 drivers/net/wireless/libertas/dev.h              |    1 +
 drivers/net/wireless/libertas/main.c             |   35 +
 drivers/net/wireless/mac80211_hwsim.c            |    3 +-
 drivers/net/wireless/mwifiex/11n_aggr.c          |    2 -
 drivers/net/wireless/mwifiex/11n_aggr.h          |    1 +
 drivers/net/wireless/mwifiex/cfg80211.c          |  176 +++-
 drivers/net/wireless/mwifiex/cfg80211.h          |    3 +-
 drivers/net/wireless/mwifiex/decl.h              |    8 -
 drivers/net/wireless/mwifiex/init.c              |    2 +-
 drivers/net/wireless/mwifiex/main.c              |  266 +----
 drivers/net/wireless/mwifiex/main.h              |   19 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c         |   46 +-
 drivers/net/wireless/mwifiex/wmm.c               |   32 +-
 drivers/net/wireless/mwl8k.c                     |    5 +-
 drivers/net/wireless/p54/main.c                  |    3 +-
 drivers/net/wireless/p54/txrx.c                  |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c          |    5 +-
 drivers/net/wireless/rt2x00/rt2800lib.c          |    5 +-
 drivers/net/wireless/rt2x00/rt2800lib.h          |    3 +-
 drivers/net/wireless/rt2x00/rt2x00.h             |    3 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c          |    3 +-
 drivers/net/wireless/rt2x00/rt61pci.c            |    5 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |    5 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c       |    3 +-
 drivers/net/wireless/rtlwifi/core.c              |    3 +-
 drivers/net/wireless/rtlwifi/usb.c               |   40 -
 drivers/net/wireless/rtlwifi/wifi.h              |    8 +-
 drivers/net/wireless/wl1251/main.c               |    3 +-
 drivers/net/wireless/wl12xx/main.c               |    3 +-
 drivers/staging/brcm80211/brcmsmac/mac80211_if.c |    7 +-
 include/linux/ieee80211.h                        |   85 ++
 include/linux/if_ether.h                         |    1 +
 include/linux/nl80211.h                          |   44 +
 include/linux/rfkill-gpio.h                      |    4 +
 include/net/bluetooth/l2cap.h                    |    3 +-
 include/net/cfg80211.h                           |   29 +
 include/net/ieee80211_radiotap.h                 |    1 +
 include/net/mac80211.h                           |  229 +++++-
 net/bluetooth/af_bluetooth.c                     |   30 +-
 net/bluetooth/bnep/core.c                        |    5 +-
 net/bluetooth/cmtp/core.c                        |    5 +-
 net/bluetooth/hci_conn.c                         |   14 +-
 net/bluetooth/hci_event.c                        |   20 +-
 net/bluetooth/hidp/core.c                        |   10 +-
 net/bluetooth/l2cap_core.c                       |  255 ++----
 net/bluetooth/rfcomm/core.c                      |    5 +-
 net/mac80211/Kconfig                             |   12 +
 net/mac80211/agg-rx.c                            |    2 +-
 net/mac80211/agg-tx.c                            |    2 +-
 net/mac80211/cfg.c                               |  380 +++++++-
 net/mac80211/debugfs_sta.c                       |   37 +-
 net/mac80211/driver-ops.h                        |   33 +-
 net/mac80211/driver-trace.h                      |   77 ++
 net/mac80211/ht.c                                |    2 +-
 net/mac80211/ibss.c                              |    4 +-
 net/mac80211/ieee80211_i.h                       |   16 +-
 net/mac80211/iface.c                             |    4 +-
 net/mac80211/key.c                               |    4 +-
 net/mac80211/main.c                              |   18 +
 net/mac80211/mesh.c                              |   58 --
 net/mac80211/mesh.h                              |    4 -
 net/mac80211/mesh_plink.c                        |   12 +-
 net/mac80211/mlme.c                              |   34 +-
 net/mac80211/pm.c                                |    2 +-
 net/mac80211/rate.c                              |    8 +-
 net/mac80211/rc80211_minstrel_ht.c               |    2 +
 net/mac80211/rx.c                                |  118 ++-
 net/mac80211/sta_info.c                          |  636 ++++++++++---
 net/mac80211/sta_info.h                          |  136 ++--
 net/mac80211/status.c                            |   54 +-
 net/mac80211/tx.c                                |  187 +++--
 net/mac80211/util.c                              |   76 ++-
 net/mac80211/wme.c                               |    4 +-
 net/rfkill/rfkill-gpio.c                         |   11 +
 net/wireless/nl80211.c                           |  109 ++-
 net/wireless/util.c                              |    5 +-
 128 files changed, 6629 insertions(+), 2696 deletions(-)
 delete mode 100644 drivers/net/wireless/ath/ath6kl/node.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/testmode.c
 create mode 100644 drivers/net/wireless/ath/ath6kl/testmode.h

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--7iMSBzlTiPOCCT2k
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJOlJseAAoJEJctW/TcYTgG7D0P/A3m6aCt4MRmZp3LbbG7Tuhu
AOcfPRJTVt1Kt1hq2sDYKLsezPlmmsBiiGo7HXoQl+lnP9X0fMzPDFKWdWq1oes7
Sjqkw4u2kX7WIIh9NfX/nJMNbzckMFFdJm8xuoBf+EUs+grlZ646qjkv1JhC3vts
s1+6hBGqpSAooXxsKL/Ko9YIIVcgf9uYWEnOwcR5bAVGSc5vnvxFSK5l1HEaov86
2rdEWzVntrJkxUvwMxen5dNJ+WjrX6zvcgWeQlHL2DouIV1aG63AluByP9bjoWVm
qvdEpNWQtxm6nM2OTkvunny6DGjszz+6YXFpBkZJSVvn4m1qnhztTibT74mJaHy6
MShsOrgRUecaAIcbxpKh5pJjTMUdMNHgjw5VOO6tiMlsbN6PZ6bA+yc4o6GYnMXH
b1ALWJpEKg23WaIO8itFTQOvKKOmXUBuzc52uOVo4MwYjBBHrrOBLPPsdS403GTN
OMDF0+MzEOr8aMTjk/QN4xHTP2qgG5aMeqKDLZ+IVIPMgF8RkrI/eTBR3P5jtHBR
R9+Q7CLK4XSmkB8Vlzqr2g0DNdov/JEzAFwW/6SDyBhUg5JbRMg/hzih8BUT34PB
+Bcw1oArRD3JuAIDmi72qj3Jo0FkaIUFzBQBjO6J9ygM7wtsDpRVSr3chCfBvW9b
e0c4DmLJBkjsgfTQNsPK
=gqgB
-----END PGP SIGNATURE-----

--7iMSBzlTiPOCCT2k--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
