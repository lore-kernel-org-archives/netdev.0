From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-09-28
Date: Fri, 28 Sep 2012 13:34:26 -0400
Message-ID: <20120928173425.GA15886@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="7JfCtLOvnd9MIVvH"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--7JfCtLOvnd9MIVvH
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit c487606f835a93a725bac1aefd536be98f22474d

Dave,

Here is another batch of updates intended for 3.7...

Highlights include an hci_connect re-write in Bluetooth, HCI/LLC
layer separation in NFC, removal of the raw pn544 NFC driver, NFC LLCP
raw sockets support, improved IBSS auth frame handling in mac80211,
full-MAC AP mode notification support in mac80211, a lot of attention
paid to brcmfmac, and the usual level of updates to iwlwifi, ath9k,
mwifiex, and rt2x00, and various other updates.

Please let me know if there are problems!

Thanks,

John

P.S.  I anticipate having at least one more pull request early in
the upcoming(?) merge window, due to some stragglers posted within
the last week...

---

The following changes since commit d9f72f359e00a45a6cd7cc2d5121b04b9dc927e1:

  Revert "be2net: fix vfs enumeration" (2012-09-27 22:19:02 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to c487606f835a93a725bac1aefd536be98f22474d:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2012-09-28 11:11:16 -0400)

----------------------------------------------------------------

Alan Cox (1):
      wireless: remove unreachable code

Amitkumar Karwar (3):
      mwifiex: fix issue in resumed scan operation
      mwifiex: disconnect the device before entering suspend state
      mwifiex: block scan request during heavy Tx traffic

Andrei Emeltchenko (7):
      Bluetooth: trivial: Shorten variable scope
      Bluetooth: trivial: Use preferred method for NULL check
      Bluetooth: Remove unneeded zero init
      Bluetooth: trivial: Make hci_chan_del return void
      Bluetooth: trivial: Remove empty line
      Bluetooth: debug: Print refcnt for hci_dev
      Bluetooth: AMP: Add Read Data Block Size to amp_init

Antonio Quartulli (2):
      mac80211: move ieee80211_send_deauth_disassoc outside mlme code
      mac80211: reply to AUTH with DEAUTH if sta allocation fails in IBSS

Arend van Spriel (8):
      cfg80211: remove obsolete comment for .sched_scan_stop() callback
      brcmfmac: add parameter check in brcmf_c_mkiovar()
      brcmfmac: simplify handling e-scan result firmware event
      brcmfmac: fix sparse warnings in e-scan related code
      brcmfmac: extend brcmf_term_iscan() to abort e-scan
      brcmfmac: introduce scheduled scan support
      brcmfmac: change struct brcmf_cfg80211_priv comments to kernel-doc
      brcmfmac: get rid of void pointer in struct brcmf_cfg80211_priv

Christian Lamparter (2):
      p54: connect to 11w protected networks
      carl9170: connect to 11w protected networks

Chun-Yeow Yeoh (2):
      mac80211: allow re-open the blocked peer link in mesh
      ath5k: disable HW crypto in management frame

Cong Wang (1):
      NFC: Remove the pn544 raw driver

Dan Carpenter (1):
      mwifiex: potential corruption in mwifiex_update_uap_custom_ie()

David Spinadel (2):
      iwlwifi: don't reset interupts after disabling
      iwlwifi: stop interrupts before stopping device

Eliad Peller (2):
      mac80211: use synchronize_net() on key destroying
      mac80211: use call_rcu() on sta deletion

Emmanuel Grumbach (2):
      iwlwifi: some clean up in transport layer
      iwlwifi: don't access the HW when it is not available

Eric Lapuyade (9):
      NFC: Changed the HCI cmd execution callback prototype
      NFC: Add a public nfc_hci_send_cmd_async method
      NFC: Modified hci_transceive to become an asynchronous operation
      NFC: Add an LLC Core layer to HCI
      NFC: Add a nop (passthrough) llc module to llc core
      NFC: Add an shdlc llc module to llc core
      NFC: Changed HCI and PN544 HCI driver to use the new HCI LLC Core
      NFC: Fix LLC registration definitions for ANSI compliance
      NFC: Add HCI module description

Felix Fietkau (1):
      mac80211: validate skb->dev in the tx status path

Franky Lin (8):
      brcmfmac: absorb brcmf_sendpkt into brcmf_netdev_start_xmit
      brcmfmac: remove obsolete sdio bus sleep mechanism
      brcmfmac: use atomic variable for interrupt pending flag
      brcmfmac: convert SDIO dpc implementation to workqueue
      brcmfmac: streamline SDIO dpc
      brcmfmac: raise SDIO host lock to higher level
      brcmfmac: clear status for in-band interrupt in brcmf_sdbrcm_isr
      brcmfmac: streamline SDIO read frame routine

Gertjan van Wingerde (7):
      rt2x00: Code clean up in rt2800lib.
      rt2x00: rt2800 - Fix default vgc values for RT3572
      rt2x00: rt2800lib - code cleanup.
      rt2x00: Code style cleanup in rt2800lib.c
      rt2x00: Clean up RFCSR1 programming in rt2800_config_channel_rf3xxx.
      rt2x00: Deprecate max_sta_intf field of struct rt2x00_ops.
      rt2x00: Replace open coded interface checking with interface combinat=
ions.

Gustavo Padovan (1):
      Bluetooth: Add USB_VENDOR_AND_INTERFACE_INFO() for Broadcom/Foxconn

Hante Meuleman (7):
      brcmfmac: fix bug causing errorneous free on exception.
      brcmfmac: fix debug printout of event data.
      brcmfmac: store usb fw images in local linked list.
      brcmfmac: remove unused function.
      brcmfmac: fix bug in determining phy bands.
      brcmfmac: remove unused usb bmac model code.
      brcmfmac: clear control lock on usb error.

Ilan Elias (3):
      NFC: Set local general bytes in nci_start_poll
      NFC: Parse NCI NFC-DEP activation params
      NFC: Implement NCI dep_link_up and dep_link_down

Jaroslav Resler (1):
      Bluetooth: Add support for BCM20702A0 [04ca, 2003]

Johan Hedberg (2):
      Bluetooth: mgmt: Implement support for passkey notification
      Bluetooth: Update management interface revision

Johannes Berg (22):
      iwlwifi: remove unused IDI code stubs
      Merge remote-tracking branch 'mac80211/master' into mac80211-next
      mac80211: don't hang on to sched_scan_ies
      mac80211: disconnect if channel switch fails
      Merge remote-tracking branch 'wireless-next/master' into mac80211-next
      wireless: remove obsolete chan no/center freq conversion functions
      mac80211_hwsim: move module_init/exit
      mac80211: check power constraint IE size when parsing
      mac80211: add key flag for management keys
      iwlwifi: fix indentation in iwl_load_given_ucode
      iwlwifi: load firmware in chunks
      mac80211: remove unneeded CONFIG_PM ifdef
      mac80211: handle power constraint/country IE better
      mac80211: change locking around ieee80211_recalc_smps
      mac80211: make reset debugfs depend on CONFIG_PM
      cfg80211: constify name parameter to add_virtual_intf
      iwlwifi: use eth_broadcast_addr
      iwlwifi: fix async station command crash
      mac80211: don't send delBA before disassoc
      mac80211: don't send delBA when removing stations
      mac80211: don't send delBA on addBA failure
      iwlegacy: use eth_broadcast_addr

John W. Linville (11):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'master' of git://git.kernel.org/.../bluetooth/bluetooth=
-next
      Merge tag 'nfc-next-3.7-1' of git://git.kernel.org/.../sameo/nfc-3.0
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      ath5k: add missing breaks in ath5k_hw_set_spur_mitigation_filter
      nfc: add dummy nfc_llc_shdlc_register definition
      NFC: Add dummy nfc_llc_shdlc_register definition
      Merge tag 'nfc-next-3.7-2' of git://git.kernel.org/.../sameo/nfc-3.0
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Michal Kazior (1):
      mac80211: refactor set_channel_type

Mikel Astiz (3):
      Bluetooth: Add more HCI error codes
      Bluetooth: Fix minor coding style in hci_event.c
      Bluetooth: mgmt: Add device disconnect reason

Ming Lei (1):
      wireless: ath9k-htc: fix possible use after free

Mohammed Shafi Shajakhan (1):
      ath9k: update hw_timer_enabled to false when we stop generic timers

Pandiyarajan Pitchaimuthu (1):
      cfg80211/nl80211: Notify connection request failure in AP mode

Paul Bolle (1):
      ipw2x00: silence GCC warning for unused variable 'dev'

Peter Senna Tschudin (6):
      net/mac80211/scan.c: removes unnecessary semicolon
      Bluetooth: bluecard_cs.c: removes unnecessary semicolon
      Bluetooth: hci_ldisc.c: removes unnecessary semicolon
      Bluetooth: hci_ll.c: removes unnecessary semicolon
      Bluetooth: hci_vhci.c: removes unnecessary semicolon
      Bluetooth: btuart_cs.c: removes unnecessary semicolon

Piotr Haber (1):
      brcmsmac: don't start device when RfKill is engaged

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: handle BCM43227

Rajkumar Manoharan (7):
      ath9k_hw: move 2g5g switch before nfcal start
      ath9k_hw: fix ar9462 selfgen chainmask
      ath9k: flush bt profile whenever it is requested
      ath9k: move coex param updation within mci work
      ath9k: fill led_pin before drv_start
      ath9k: fix queuing MCI work twice
      ath9k_hw: fix BT sleep state on chip wakeup

Sachin Kamat (1):
      Bluetooth: Use module_platform_driver() in btwilink.c file

Samuel Ortiz (4):
      NFC: Queue pn533 commands
      NFC: Set the IRQF_ONESHOT flag from the pn544_hci IRQ handler request
      NFC: Remove unneeded LLC symbols export
      MAINTAINERS: Add NFC specific mailing list

Sujith Manoharan (10):
      ath9k: Enable SGI correctly
      ath9k_hw: Use HW cap ATH9K_HW_CAP_ANT_DIV_COMB
      ath9k: Remove redundant variable assignment
      ath9k: Remove a couple of unused variables
      ath9k_hw: Add antenna diversity group for AR9565
      ath9k_hw: Update AR9565 initvals
      ath9k_hw: Add a HW callback to set diversity
      ath9k: Add a module parameter to enable diversity
      ath9k_hw: Enable WLAN RX diversity for AR9565
      ath9k: Disable ASPM only for AR9285

Syam Sidhardhan (4):
      Bluetooth: debug: Correct the PSM printing
      Bluetooth: Use kref for l2cap channel reference counting
      NFC: Use module_platform_driver macro for nfcwilink.c
      NFC: Remove repeated code for NULL check

Sylvain Roger Rieunier (1):
      mac80211: fix IBSS auth TX debug message

Szymon Janc (4):
      NFC: Use dynamic initialization for rwlocks
      NFC: Fix missing mutex unlock in pn533_send_cmd_frame_async
      NFC: Fix sleeping in invalid context when netlink socket is closed
      NFC: Fix sleeping in atomic when releasing socket

Tejun Heo (2):
      NFC: Use system_nrt_wq instead of custom ones
      NFC: Don't use WQ_MEM_RECLAIM for pn533

Thierry Escande (1):
      NFC: LLCP raw socket support

Vinicius Costa Gomes (8):
      Bluetooth: Remove some functions from being exported
      Bluetooth: Rename LE and ACL connection functions
      Bluetooth: Refactor LE connection into its own function
      Bluetooth: Refactor ACL connection into its own function
      Bluetooth: Refactor SCO connection into its own function
      Bluetooth: Simplify a the connection type handling
      Bluetooth: Add type information to the hci_connect() debug statement
      Bluetooth: Fix establishing ESCO links

Vitaly Wool (1):
      rfkill: prevent unnecessary event generation

Vladimir Kondratiev (1):
      cfg80211: Fix regulatory check for 60GHz band frequencies

Waldemar Rymarkiewicz (6):
      NFC: Remove crc generation from shdlc layer
      NFC: Correct outgoing frame before requeueing
      NFC: xmit from hci ops must return 0 or negative
      NFC: Handle RSET in SHDLC_CONNECTING state
      NFC: Don't handle consequent RSET frames after UA
      NFC: Fix typo negociating -> negotiating

Wei Yongjun (6):
      mac80211: use list_move instead of list_del/list_add
      Bluetooth: btmrvl: remove pointless conditional before kfree_skb()
      NFC: Remove pointless conditional before HCI kfree_skb()
      NFC: Fix possible LLCP memory leak
      NFC: Move the nfcwilink dereference below the NULL test
      NFC: Move the pn544_hci dereference below the NULL test

 Documentation/feature-removal-schedule.txt         |   12 -
 MAINTAINERS                                        |    1 +
 drivers/bcma/host_pci.c                            |    1 +
 drivers/bcma/sprom.c                               |    2 +
 drivers/bluetooth/bluecard_cs.c                    |    2 +-
 drivers/bluetooth/btmrvl_sdio.c                    |    3 +-
 drivers/bluetooth/btuart_cs.c                      |    2 +-
 drivers/bluetooth/btusb.c                          |    3 +-
 drivers/bluetooth/btwilink.c                       |   16 +-
 drivers/bluetooth/hci_ldisc.c                      |    2 +-
 drivers/bluetooth/hci_ll.c                         |    2 +-
 drivers/bluetooth/hci_vhci.c                       |    2 +-
 drivers/net/wireless/ath/ath.h                     |    1 +
 drivers/net/wireless/ath/ath5k/base.c              |    1 +
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    5 +-
 drivers/net/wireless/ath/ath5k/phy.c               |    2 +
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    4 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |    2 +-
 drivers/net/wireless/ath/ath9k/antenna.c           |  117 ++-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   20 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |    7 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.h        |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   66 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.h        |   24 +
 .../net/wireless/ath/ath9k/ar9565_1p0_initvals.h   |  100 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    6 +-
 drivers/net/wireless/ath/ath9k/gpio.c              |   58 +-
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    5 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |    2 +-
 drivers/net/wireless/ath/ath9k/hw-ops.h            |    7 +
 drivers/net/wireless/ath/ath9k/hw.c                |   12 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    3 +-
 drivers/net/wireless/ath/ath9k/init.c              |   13 +
 drivers/net/wireless/ath/ath9k/main.c              |    2 +-
 drivers/net/wireless/ath/ath9k/mci.c               |   62 +-
 drivers/net/wireless/ath/ath9k/pci.c               |    5 +-
 drivers/net/wireless/ath/ath9k/rc.c                |   11 +-
 drivers/net/wireless/ath/carl9170/mac.c            |    3 +-
 drivers/net/wireless/ath/carl9170/main.c           |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   39 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |   25 -
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |    4 -
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   19 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |    2 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   41 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c | 1037 ++++++++--------=
----
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |    2 +
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   90 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  422 ++++++--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |  202 +++-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |    5 +-
 drivers/net/wireless/ipw2x00/libipw_wx.c           |    2 +-
 drivers/net/wireless/iwlegacy/common.c             |    4 +-
 drivers/net/wireless/iwlwifi/dvm/scan.c            |    4 +-
 drivers/net/wireless/iwlwifi/dvm/sta.c             |    7 +-
 drivers/net/wireless/iwlwifi/dvm/ucode.c           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   26 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |    3 +-
 drivers/net/wireless/iwlwifi/pcie/drv.c            |   13 -
 drivers/net/wireless/iwlwifi/pcie/internal.h       |    2 +-
 drivers/net/wireless/iwlwifi/pcie/rx.c             |   75 +-
 drivers/net/wireless/iwlwifi/pcie/trans.c          |   84 +-
 drivers/net/wireless/mac80211_hwsim.c              |    5 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |    8 +-
 drivers/net/wireless/mwifiex/ie.c                  |    2 +-
 drivers/net/wireless/mwifiex/init.c                |    1 +
 drivers/net/wireless/mwifiex/main.h                |    4 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   13 +
 drivers/net/wireless/p54/main.c                    |   12 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |    1 -
 drivers/net/wireless/rt2x00/rt2500pci.c            |    1 -
 drivers/net/wireless/rt2x00/rt2500usb.c            |    1 -
 drivers/net/wireless/rt2x00/rt2800lib.c            |   72 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    1 -
 drivers/net/wireless/rt2x00/rt2800usb.c            |    1 -
 drivers/net/wireless/rt2x00/rt2x00.h               |   15 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |   33 +
 drivers/net/wireless/rt2x00/rt2x00mac.c            |   40 -
 drivers/net/wireless/rt2x00/rt61pci.c              |    1 -
 drivers/net/wireless/rt2x00/rt73usb.c              |    1 -
 drivers/nfc/Kconfig                                |   14 +-
 drivers/nfc/Makefile                               |    1 -
 drivers/nfc/nfcwilink.c                            |   20 +-
 drivers/nfc/pn533.c                                |  107 +-
 drivers/nfc/pn544.c                                |  893 -----------------
 drivers/nfc/pn544_hci.c                            |  177 ++--
 include/linux/ieee80211.h                          |   80 --
 include/linux/nfc.h                                |   11 +
 include/linux/nl80211.h                            |   24 +
 include/net/bluetooth/hci.h                        |   21 +
 include/net/bluetooth/hci_core.h                   |   26 +-
 include/net/bluetooth/l2cap.h                      |    3 +-
 include/net/bluetooth/mgmt.h                       |   16 +
 include/net/cfg80211.h                             |   25 +-
 include/net/mac80211.h                             |   12 +-
 include/net/nfc/hci.h                              |   21 +-
 include/net/nfc/llc.h                              |   54 +
 include/net/nfc/nci.h                              |   29 +
 include/net/nfc/nci_core.h                         |    5 +
 include/net/nfc/nfc.h                              |    2 +-
 include/net/nfc/shdlc.h                            |  107 --
 net/bluetooth/af_bluetooth.c                       |   10 +-
 net/bluetooth/hci_conn.c                           |  100 +-
 net/bluetooth/hci_core.c                           |    6 +-
 net/bluetooth/hci_event.c                          |   99 +-
 net/bluetooth/l2cap_core.c                         |   17 +-
 net/bluetooth/mgmt.c                               |   28 +-
 net/mac80211/agg-tx.c                              |    2 +-
 net/mac80211/cfg.c                                 |   37 +-
 net/mac80211/chan.c                                |   67 +-
 net/mac80211/debugfs.c                             |    4 +
 net/mac80211/ibss.c                                |   35 +-
 net/mac80211/ieee80211_i.h                         |   23 +-
 net/mac80211/iface.c                               |   15 +-
 net/mac80211/key.c                                 |    2 +-
 net/mac80211/main.c                                |   10 +-
 net/mac80211/mesh_plink.c                          |    3 +-
 net/mac80211/mlme.c                                |  207 ++--
 net/mac80211/offchannel.c                          |    3 +-
 net/mac80211/scan.c                                |   41 +-
 net/mac80211/sta_info.c                            |  123 +--
 net/mac80211/sta_info.h                            |    2 +
 net/mac80211/status.c                              |   48 +-
 net/mac80211/tx.c                                  |    2 +-
 net/mac80211/util.c                                |   51 +-
 net/nfc/core.c                                     |   13 +-
 net/nfc/hci/Makefile                               |    4 +-
 net/nfc/hci/command.c                              |   45 +-
 net/nfc/hci/core.c                                 |  336 ++++---
 net/nfc/hci/hci.h                                  |   15 +-
 net/nfc/hci/hcp.c                                  |    6 +-
 net/nfc/hci/llc.c                                  |  170 ++++
 net/nfc/hci/llc.h                                  |   69 ++
 net/nfc/hci/llc_nop.c                              |   99 ++
 net/nfc/hci/{shdlc.c =3D> llc_shdlc.c}               |  544 +++++-----
 net/nfc/llcp/commands.c                            |    2 +
 net/nfc/llcp/llcp.c                                |  131 +--
 net/nfc/llcp/llcp.h                                |    6 +-
 net/nfc/llcp/sock.c                                |   93 +-
 net/nfc/nci/core.c                                 |   91 +-
 net/nfc/nci/ntf.c                                  |   52 +
 net/nfc/nci/rsp.c                                  |   14 +
 net/nfc/netlink.c                                  |   46 +-
 net/rfkill/core.c                                  |    8 +-
 net/wireless/mlme.c                                |   11 +
 net/wireless/nl80211.c                             |   34 +
 net/wireless/nl80211.h                             |    5 +
 net/wireless/reg.c                                 |   39 +-
 148 files changed, 3919 insertions(+), 3413 deletions(-)
 delete mode 100644 drivers/nfc/pn544.c
 create mode 100644 include/net/nfc/llc.h
 delete mode 100644 include/net/nfc/shdlc.h
 create mode 100644 net/nfc/hci/llc.c
 create mode 100644 net/nfc/hci/llc.h
 create mode 100644 net/nfc/hci/llc_nop.c
 rename net/nfc/hci/{shdlc.c =3D> llc_shdlc.c} (54%)
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--7JfCtLOvnd9MIVvH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJQZd+hAAoJEJctW/TcYTgGrwkP/AuJoKBDfPKZtWN19gkrvWdP
WC9GzzfHDbgZmkMPtUV75748qdybUaVxf9aT3+i8wbijNmRsXitGASI4sA/Ey9yh
yEqSiw4o3s1h9cp1nUamgV28GhPY1Qy6tls9SVnjV4yGWcVVTYWDDPqgorK6pBau
gLIUF6SGosszMosCB4soX0FhVpMhhHr96PzGuTZ/Z1O+WuSPlelWaOAqLlJuuYO5
Ahb+YZL5df3akFP6iIiR4sdfBs4zp/+nc0eGc8t3f+vLmLXfiUih8nyJyl4SkjYe
IX4tSZ4BhkujYJjcgVpvC2AYFNMreTfnYMz1OHE+4wWzLim6euiyXkrsSCEiRXNg
pWdpvpJXMPiMilhP1zKnGKj8PAKpzDa4hjA7FTfQjL9W04GDmm5afI6cm+e71bi0
Mbu05LoCMArSa5kSwWB8zJ1WAfcKMtSYjImrrVKmZXo+8yrhUBHRUyvpGPUh91Hb
jl4mpATY0GFP63kPrcJ662ma/C7gxlN6kuG0bNBkz+/Si6axBwM/p1tQpLVWbz7D
7npSm3zkRKbdYDcSxhBwM2ChFwmTX3/w1PZRi0GmjbU3kHG1WqEH4rmc86yCIfT9
w7B/a8jRKVcVWLybvmBXff6TRRAspZfUMHrkThEiBG1lZgiZPeFlu7slC0F7P2Af
gMaBcHlqrkATJ4ft43BZ
=addF
-----END PGP SIGNATURE-----

--7JfCtLOvnd9MIVvH--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
