From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2012-05-03
Date: Thu, 3 May 2012 11:22:06 -0400
Message-ID: <20120503152206.GL9285@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vtzGhvizbBRQ85DL"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit aeace1b7293095fd45240646343251b1da8713da

Dave,

This is a batch of updates intended for 3.5.  It also includes a pull
=66rom the wireless tree which resolved some build dependencies.

Highlights of this pull request include some refactoring in the
bluetooth directories, some HT enhancements for mac80211, an expansion
of the ethtool support for cfg80211- and mac80211-based drivers,
and some more iwlwifi refactoring.

It looks like some of the bluetooth device ID patches got committed
on both the bluetooth and the bluetooth-next trees.  I'll ask them to
be more careful about that, but I didn't think it was worth asking
for rebases since that would be disruptive to the downstream trees
and since git handles the situation reasonably well already.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit af94bf6db1d58d26f1cdab145b6312ad363254a6:

  ixgbe: Fix use after free on module remove (2012-05-03 04:21:34 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

AceLan Kao (5):
      Bluetooth: Add support for Atheros [04ca:3005]
      Bluetooth: Add support for Atheros [13d3:3362]
      Bluetooth: Add support for Atheros [13d3:3362]
      Bluetooth: Add support for AR3012 [0cf3:e004]
      Bluetooth: Add support for AR3012 [0cf3:e004]

Amitkumar Karwar (1):
      mwifiex: fix static checker warnings

Andre Guedes (10):
      Bluetooth: Check FINDING state in interleaved discovery
      Bluetooth: Add hci_cancel_le_scan() to hci_core
      Bluetooth: LE support for MGMT stop discovery
      Bluetooth: Replace EPERM by EALREADY in hci_cancel_inquiry
      Bluetooth: Refactor stop_discovery
      Bluetooth: Add Periodic Inquiry command complete handler
      Bluetooth: Add HCI_PERIODIC_INQ to dev_flags
      Bluetooth: Check HCI_PERIODIC_INQ in start_discovery
      Bluetooth: Ignore inquiry results from periodic inquiry
      Bluetooth: Remove MGMT_ADDR_INVALID macro

Andrei Emeltchenko (27):
      Bluetooth: Correct type for hdev lmp_subver
      Bluetooth: trivial: Correct endian conversion
      Bluetooth: Correct type for ediv to __le16
      Bluetooth: Fix extra conversion to __le32
      Bluetooth: Correct chan->psm endian conversions
      Bluetooth: Correct ediv in SMP
      Bluetooth: Correct length calc in L2CAP conf rsp
      Bluetooth: Correct CID endian notation
      Bluetooth: Convert error codes to le16
      Bluetooth: trivial: Fix endian conversion mode
      Bluetooth: mgmt: Add missing endian conversion
      Bluetooth: trivial: Correct types
      Bluetooth: Fix type in cpu_to_le conversion
      Bluetooth: Fix opcode access in hci_complete
      Bluetooth: trivial: Remove sparse warnings
      Bluetooth: Silence sparse warning
      Bluetooth: mgmt: Fix timeout type
      Bluetooth: Remove unneeded timer clear
      Bluetooth: Fix memory leaks due to chan refcnt
      Bluetooth: Make L2CAP chan_add functions static
      Bluetooth: Comments and style fixes
      Bluetooth: Remove unneeded zero initialization
      Bluetooth: Add Read Local AMP Info to init
      Bluetooth: Adds set_default function in L2CAP setup
      Bluetooth: trivial: Remove empty line
      Bluetooth: Fix debug printing unallocated name
      cfg80211: Remove compile warnings

Anisse Astier (2):
      rt2x00: debugfs support - allow a register to be empty
      rt2x00: Add debugfs access for rfcsr register

Ashok Nagarajan (4):
      mac80211: Advertise HT protection mode in IEs
      mac80211: Implement HT mixed protection mode
      mac80211: Allow nonHT/HT peering in mesh
      {nl,cfg,mac}80211: Allow user to see/configure HT protection mode

Ben Greear (4):
      cfg80211: Add framework to support ethtool stats.
      mac80211: Support getting sta_info stats via ethtool.
      mac80211: Framework to get wifi-driver stats via ethtool.
      mac80211: Add more ethtools stats: survey, rates, etc

Ben Hutchings (2):
      ipw2200: Fix order of device registration
      ipw2100: Fix order of device registration

Brian Gix (1):
      Bluetooth: mgmt: Fix corruption of device_connected pkt

Cho, Yu-Chen (1):
      Bluetooth: Add Atheros maryann PIDVID support

Dan Carpenter (1):
      wireless: at76c50x: allocating too much data

David Herrmann (5):
      Bluetooth: Remove redundant hdev->parent field
      Bluetooth: vhci: Ignore return code of nonseekable_open()
      Bluetooth: Move hci_alloc/free_dev close to hci_register/unregister_d=
ev
      Bluetooth: Move device initialization to hci_alloc_dev()
      Bluetooth: Remove unneeded initialization in hci_alloc_dev()

Don Zickus (1):
      Bluetooth: btusb: typo in Broadcom SoftSailing id

Eldad Zack (1):
      brcmsmac: "INTERMEDIATE but not AMPDU" only when tracing

Eliad Peller (1):
      mac80211: call ieee80211_mgd_stop() on interface stop

Emmanuel Grumbach (3):
      iwlwifi: use IWL_* instead of dev_printk when possible
      iwlwifi: don't init trans->reg_lock from the op_mode
      cfg80211: fix BSS comparison

Felix Fietkau (1):
      mac80211: fix AP mode EAP tx for VLAN stations

Franky Lin (6):
      brcm80211: fmac: fix SDIO function 0 register r/w issue
      brcm80211: fmac: fix missing completion events issue
      brcmfmac: stop releasing sdio host in irq handler
      brcmfmac: check bus state for status
      brcmfmac: postpone interrupt register function
      brcmfmac: add out of band interrupt support

Gabor Juhos (2):
      ath9k: add an extra boolean parameter to ath9k_hw_apply_txpower
      ath9k: fix tx power settings for AR9287

Grazvydas Ignotas (2):
      wl1251: fix crash on remove due to premature kfree
      wl1251: fix crash on remove due to leftover work item

Gustavo Padovan (6):
      Bluetooth: Remove sk parameter from l2cap_chan_create()
      Bluetooth: Fix userspace compatibility issue with mgmt interface
      Merge git://git.kernel.org/.../bluetooth/bluetooth
      Bluetooth: Remove err parameter from alloc_skb()
      Bluetooth: remove unneeded declaration of sco_conn_del()
      Bluetooth: Fix coding style issues

Hemant Gupta (6):
      Bluetooth: Use correct flags for checking HCI_SSP_ENABLED bit
      Bluetooth: Send correct address type for LTK
      Bluetooth: Fix clearing discovery type when stopping discovery
      Bluetooth: mgmt: Fix missing connect failed event for LE
      Bluetooth: mgmt: Fix address type while loading Long Term Key
      Bluetooth: Don't distribute keys in case of Encryption Failure

Ido Yariv (1):
      Bluetooth: Search global l2cap channels by src/dst addresses

Jesper Juhl (1):
      Bluetooth: btmrvl_sdio: remove pointless conditional before release_f=
irmware()

Johan Hedberg (2):
      Bluetooth: Don't increment twice in eir_has_data_type()
      Bluetooth: Check for minimum data length in eir_has_data_type()

Johan Hovold (2):
      Bluetooth: hci_ldisc: fix NULL-pointer dereference on tty_close
      Bluetooth: hci_core: fix NULL-pointer dereference at unregister

Johannes Berg (1):
      iwlwifi: fix hardware queue programming

John W. Linville (5):
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'wireless-next' of git://git.kernel.org/.../iwlwifi/iwlw=
ifi
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jonathan Bither (1):
      ath5k: add missing iounmap to AHB probe removal

Jo=E3o Paulo Rechi Vita (1):
      Bluetooth: btusb: Add USB device ID "0a5c 21e8"

Larry Finger (1):
      rtlwifi: Fix oops on unload

Luis R. Rodriguez (2):
      Bluetooth: properly use pr_fmt() on lib.c
      libertas: include sched.h on firmware.c

Lukasz Rymanowski (1):
      Bluetooth: Remove not needed status parameter

Manoj Iyer (2):
      Bluetooth: btusb: Add vendor specific ID (0489 e042) for BCM20702A0
      Bluetooth: btusb: Add vendor specific ID (0489 e042) for BCM20702A0

Marcel Holtmann (10):
      Bluetooth: Add TX power tag to EIR data
      Bluetooth: Handle EIR tags for Device ID
      Bluetooth: Add management command for setting Device ID
      Bluetooth: Fix broken usage of put_unaligned_le16
      Bluetooth: Fix broken usage of get_unaligned_le16
      Bluetooth: Update management interface revision
      Bluetooth: Split error handling for L2CAP listen sockets
      Bluetooth: Split error handling for SCO listen sockets
      Bluetooth: Don't check source address in SCO bind function
      Bluetooth: Restrict to one SCO listening socket

Mat Martineau (4):
      Bluetooth: Add definitions and struct members for new ERTM state mach=
ine
      Bluetooth: Add a structure to carry ERTM data in skb control blocks
      Bluetooth: Add the l2cap_seq_list structure for tracking frames
      Bluetooth: Functions for handling ERTM control fields

Meenakshi Venkataraman (1):
      iwlwifi: use correct released ucode version

Mikel Astiz (3):
      Bluetooth: Use unsigned int instead of signed int
      Bluetooth: Remove unnecessary check
      Bluetooth: btusb: Dynamic alternate setting

Rajkumar Manoharan (1):
      mac80211: fix rate control update on 2040 bss change

Santosh Nayak (1):
      Bluetooth: Fix Endian Bug.

Seth Forshee (1):
      b43: only reload config after successful initialization

Stanislav Yakovlev (2):
      ipw2200: Fix race condition in the command completion acknowledge
      net/wireless: ipw2200: Fix WARN_ON occurring in wiphy_register called=
 by ipw_pci_probe

Stanislaw Gruszka (2):
      iwlwifi: do not nulify ctx->vif on reset
      iwlwifi: add option to disable 5GHz band

Steven Harms (2):
      Add Foxconn / Hon Hai IDs for btusb module
      Add Foxconn / Hon Hai IDs for btusb module

Syam Sidhardhan (3):
      Bluetooth: remove header declared but not defined
      Bluetooth: Remove strtoba header declared but not defined
      Bluetooth: mgmt: Remove unwanted goto statements

Szymon Janc (4):
      Bluetooth: mgmt: Fix some code style and indentation issues
      Bluetooth: mgmt: Don't allow to set invalid value to DeviceID source
      Bluetooth: Fix missing break in hci_cmd_complete_evt
      Bluetooth: Fix missing break in hci_cmd_complete_evt

Thomas Pedersen (2):
      mac80211: insert mesh peer after init
      mac80211: don't transmit 40MHz frames to 20MHz peer

Ulisses Furquim (1):
      Bluetooth: Fix registering hci with duplicate name

Vinicius Costa Gomes (1):
      Bluetooth: Add support for reusing the same hci_conn for LE links

Vishal Agarwal (4):
      Bluetooth: hci_persistent_key should return bool
      Bluetooth: Temporary keys should be retained during connection
      Bluetooth: hci_persistent_key should return bool
      Bluetooth: Temporary keys should be retained during connection

WarheadsSE (1):
      mwifiex: add support for SD8786 sdio

Wey-Yi Guy (11):
      iwlwifi: remove unused macros
      iwlwifi: add BT reduced tx power flag
      iwlwifi: add checking for the condition to reduce tx power
      iwlwifi: add reduced tx power threshold define
      iwlwifi: small define change
      iwlwifi: send reduce tx power info in command
      iwlwifi: change kill mask based on reduce power state
      iwlwifi: add loose coex lut
      iwlwifi: use 6000G2B for 6030 device series
      iwlwifi: modify #ifdef to avoid sparse complain
      iwlwifi: remove the iwl_shared reference

 drivers/bluetooth/ath3k.c                          |    4 +
 drivers/bluetooth/btmrvl_sdio.c                    |    9 +-
 drivers/bluetooth/btusb.c                          |   19 +-
 drivers/bluetooth/hci_ldisc.c                      |    2 +-
 drivers/bluetooth/hci_vhci.c                       |    3 +-
 drivers/net/wireless/at76c50x-usb.c                |    4 +-
 drivers/net/wireless/ath/ath5k/ahb.c               |    1 +
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_paprd.c      |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |    2 +
 drivers/net/wireless/ath/ath9k/hw.c                |    9 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    3 +-
 drivers/net/wireless/b43/main.c                    |   10 +-
 drivers/net/wireless/brcm80211/Kconfig             |    9 +
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   97 ++++-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |  113 +++++-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  102 ++++-
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   22 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    3 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |   24 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |   57 ++--
 drivers/net/wireless/iwlwifi/iwl-1000.c            |    8 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   16 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   11 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |   10 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  153 +++----
 drivers/net/wireless/iwlwifi/iwl-agn.c             |   41 +-
 drivers/net/wireless/iwlwifi/iwl-agn.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |   21 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h             |    1 +
 drivers/net/wireless/iwlwifi/iwl-drv.c             |   12 +-
 drivers/net/wireless/iwlwifi/iwl-fh.h              |   22 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |   10 +-
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    8 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   27 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    1 +
 drivers/net/wireless/libertas/firmware.c           |    1 +
 drivers/net/wireless/mwifiex/Kconfig               |    4 +-
 drivers/net/wireless/mwifiex/fw.h                  |    3 +-
 drivers/net/wireless/mwifiex/sdio.c                |    7 +
 drivers/net/wireless/mwifiex/sdio.h                |    1 +
 drivers/net/wireless/rt2x00/rt2800.h               |    2 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |    7 +
 drivers/net/wireless/rt2x00/rt2x00debug.c          |   82 ++--
 drivers/net/wireless/rt2x00/rt2x00debug.h          |    1 +
 drivers/net/wireless/rtlwifi/pci.c                 |    1 +
 drivers/net/wireless/ti/wl1251/main.c              |    1 +
 drivers/net/wireless/ti/wl1251/sdio.c              |    2 +-
 include/linux/nl80211.h                            |    3 +
 include/net/bluetooth/bluetooth.h                  |   14 +-
 include/net/bluetooth/hci.h                        |    7 +
 include/net/bluetooth/hci_core.h                   |   21 +-
 include/net/bluetooth/l2cap.h                      |   78 +++-
 include/net/bluetooth/mgmt.h                       |    9 +
 include/net/bluetooth/smp.h                        |    2 +-
 include/net/cfg80211.h                             |   18 +
 include/net/mac80211.h                             |   17 +
 net/bluetooth/hci_conn.c                           |   32 +-
 net/bluetooth/hci_core.c                           |  206 +++++-----
 net/bluetooth/hci_event.c                          |   61 +++-
 net/bluetooth/hci_sysfs.c                          |    5 +-
 net/bluetooth/l2cap_core.c                         |  454 ++++++++++++++++=
----
 net/bluetooth/l2cap_sock.c                         |   33 +-
 net/bluetooth/lib.c                                |    2 +
 net/bluetooth/mgmt.c                               |  225 +++++++----
 net/bluetooth/sco.c                                |   72 ++--
 net/bluetooth/smp.c                                |    2 +-
 net/mac80211/cfg.c                                 |  182 ++++++++
 net/mac80211/driver-ops.h                          |   37 ++
 net/mac80211/driver-trace.h                        |   15 +
 net/mac80211/ibss.c                                |    2 +-
 net/mac80211/ieee80211_i.h                         |    5 +-
 net/mac80211/iface.c                               |    4 +-
 net/mac80211/mesh.c                                |   18 +-
 net/mac80211/mesh_plink.c                          |   96 ++++-
 net/mac80211/mlme.c                                |    4 +-
 net/mac80211/sta_info.h                            |    1 +
 net/mac80211/tx.c                                  |    3 +-
 net/mac80211/util.c                                |    9 +-
 net/wireless/ethtool.c                             |   29 ++
 net/wireless/mesh.c                                |    1 +
 net/wireless/nl80211.c                             |    7 +-
 net/wireless/scan.c                                |    6 +-
 net/wireless/util.c                                |    3 +-
 85 files changed, 1972 insertions(+), 665 deletions(-)
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--vtzGhvizbBRQ85DL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPoqKdAAoJEJctW/TcYTgGz50P/2emjdHRDsySewvP/McJ49/d
+S5hdIQJZ2E5o1D6fBXZUuaXKulTJXnCRAVgoFfZb9t9TEdrBO4DoqdJV8Q9ojYX
Li2GAcjN4TjuIFjeg/m15iy153WAAQ3ePj3xfQGZpVGTKf+KCFMg/UIPqvy72Mdv
FiXc7YhLddHs2dWvzE2mSNaAhUxmP3nI/CK945pk4CHYlYlyqPkzdKGiF/UYEaYy
NEwB8B7+ljcbnmOu//viZps7oerbkzs8OzYhnh6uibqczjC0s4FPWnPpGYBxq53L
x2wA8BNQOAbrHb2acjUov855anrGMpTR8ASP46KcUfhDdQQc+5R3rR5/E/Nc/BsW
+cGrEgOP2JyeITz/jB/9r3lnKC7PR1Xb/lvY3qav7kI4zhre5Q6kjobOSqc5z5Hv
hQ9rbBgy4peJ9SYpGX6CXCWHWx2w1iv6DC3T4V60SfAwimoYhVoSSmIU31ea8x8p
tbUCEFZMYWqyHofrcbjBLt0HyMYHZK9w//a9nss2nVWdKn1CF+d7v5kKCIkjKRiM
6GrT1sZyXURKuIbHzV+KRz9RlPW9ewbDyw+AGqGmisNIxOvqZ3KW+bGpkbpWJ1zr
yZImv3eeWsbYKDxdV4GNddUvCaP0ySJVm1uVR6LQ2rJdO5rI9H/S0w3+Z2D5IUn2
2HKhL90et4UVPKKm17lt
=FvQs
-----END PGP SIGNATURE-----

--vtzGhvizbBRQ85DL--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
