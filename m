From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2012-05-22
Date: Tue, 22 May 2012 15:53:48 -0400
Message-ID: <20120522195347.GF11866@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="Fba/0zbH8Xs+Fj9o"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--Fba/0zbH8Xs+Fj9o
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit a0d0d1685f9763ab26a394df3ab84026b39a06a7

Dave,

I apologize for not having sent this sooner.  FWIW, I was in a car
somewhere between Illinois and North Carolina for most of the day
Sunday and Monday... :-)

This is (obviously) the last non-fix pull request for wireless bits
intended for 3.5.  It includes AP support for mwifiex, a variety of HCI
and other updates for NFC, some brcmfmac and brcmsmac refactoring,
a large batch of ssb and bcma updates, a batch of ath6kl updates,
some cfg80211 and mac80211 updates/refactoring from Johannes Berg,
a rather large collection of Bluetooth updates by way of Gustavo,
and a variety of other bits here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 31a67102f4762df5544bc2dfb34a931233d2a5b2:

  Fix blocking allocations called very early during bootup (2012-05-21 12:5=
2:42 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git master

Amit Beka (1):
      iwlwifi: fix power index handling

Amitkumar Karwar (2):
      Bluetooth: btmrvl: configure default host sleep parameters
      Bluetooth: btmrvl: add support for SDIO suspend/resume callbacks

Andre Guedes (21):
      Bluetooth: Check FINDING state in interleaved discovery
      Bluetooth: Add hci_cancel_le_scan() to hci_core
      Bluetooth: LE support for MGMT stop discovery
      Bluetooth: Replace EPERM by EALREADY in hci_cancel_inquiry
      Bluetooth: Refactor stop_discovery
      Bluetooth: Add Periodic Inquiry command complete handler
      Bluetooth: Add HCI_PERIODIC_INQ to dev_flags
      Bluetooth: Check HCI_PERIODIC_INQ in start_discovery
      Bluetooth: Ignore inquiry results from periodic inquiry
      Bluetooth: Add Periodic Inquiry command complete handler
      Bluetooth: Add HCI_PERIODIC_INQ to dev_flags
      Bluetooth: Remove MGMT_ADDR_INVALID macro
      Bluetooth: Remove useless code in hci_connect
      Bluetooth: Move address type macros to bluetooth.h
      Bluetooth: Rename link_to_mgmt to link_to_bdaddr
      Bluetooth: Add address type to struct sockaddr_l2
      Bluetooth: Rename mgmt_to_le to bdaddr_to_le
      Bluetooth: Move bdaddr_to_le to hci_core
      Bluetooth: Add dst_type parameter to hci_connect
      Bluetooth: Use address type info from user-space
      Bluetooth: Remove advertising cache

Andrei Emeltchenko (24):
      Bluetooth: trivial: Correct endian conversion
      Bluetooth: Correct type for hdev lmp_subver
      Bluetooth: Correct type for ediv to __le16
      Bluetooth: Fix extra conversion to __le32
      Bluetooth: Correct chan->psm endian conversions
      Bluetooth: Correct ediv in SMP
      Bluetooth: Correct length calc in L2CAP conf rsp
      Bluetooth: Correct CID endian notation
      Bluetooth: Convert error codes to le16
      Bluetooth: trivial: Fix endian conversion mode
      Bluetooth: trivial: Correct types
      Bluetooth: Fix type in cpu_to_le conversion
      Bluetooth: Fix opcode access in hci_complete
      Bluetooth: trivial: Remove sparse warnings
      Bluetooth: Silence sparse warning
      Bluetooth: Comments and style fixes
      Bluetooth: Remove unneeded timer clear
      Bluetooth: Make L2CAP chan_add functions static
      Bluetooth: Remove unneeded zero initialization
      Bluetooth: Add Read Local AMP Info to init
      Bluetooth: Adds set_default function in L2CAP setup
      Bluetooth: Fix debug printing unallocated name
      Bluetooth: trivial: Remove empty line
      Bluetooth: Remove unneeded calculation and magic number

Arik Nemtsov (1):
      mac80211: fix network header location when adding encryption headers

Ashok Nagarajan (4):
      mac80211: Push the deleted comment to correct place
      mac80211: Fix don't use '>' operator for matching channel types
      mac80211: Modify mesh_set_ht_prot_mode() to have less identation
      mac80211: Add debugfs entry for mesh ht_opmode

Avinash Patil (18):
      mwifiex: allocate space for one more mwifiex_private structure
      mwifiex: handle station specific commands on STA interface only
      mwifiex: support for creation of AP interface
      mwifiex: multi-interface support for mwifiex
      mwifiex: save adapter pointer in wiphy_priv
      mwifiex: append peer mac address TLV in key material command to firmw=
are
      mwifiex: add bss start and bss stop commands for AP
      mwifiex: add AP command sys_config and set channel
      mwifiex: stop BSS in deauthentication handling
      mwifiex: handle interface type changes correctly
      mwifiex: common set_wiphy_params cfg80211 handler for AP and STA inte=
rface
      mwifiex: add cfg80211 start_ap and stop_ap handlers
      mwifiex: add AP event handling framework
      mwifiex: add WPA2 support for AP
      mwifiex: rearrange AP sys configure code
      mwifiex: add custom IE framework
      mwifiex: retrieve IEs from cfg80211_beacon_data and send to firmware
      mwifiex: delete IEs when stop_ap

Bartosz.Markowski@tieto.com (1):
      wlcore/wl12xx: implement better beacon loss handling

Bing Zhao (1):
      mwifiex: fix coding style issue in mwifiex_deauthenticate

Bjorn Helgaas (1):
      b43: use pci_is_pcie() instead of obsolete pci_dev.is_pcie

Chun-Yeow Yeoh (1):
      mac80211: fix the increment of unicast/multicast counters for forward=
ed PREQ

Cristian Chilipirea (2):
      Bluetooth: Fixed checkpatch warnings
      Net: wireless: core.c: fixed checkpatch warnings

Dan Carpenter (6):
      ath6kl: list_first_entry() is never NULL
      ath6kl: change || to &&
      ath6kl: fix an indenting issue
      NFC: Remove unneeded pn533 dev NULL check
      wlcore: release lock on error in wl1271_op_suspend()
      wlcore: fixup an allocation

David Herrmann (5):
      Bluetooth: Remove redundant hdev->parent field
      Bluetooth: vhci: Ignore return code of nonseekable_open()
      Bluetooth: Move hci_alloc/free_dev close to hci_register/unregister_d=
ev
      Bluetooth: Move device initialization to hci_alloc_dev()
      Bluetooth: Remove unneeded initialization in hci_alloc_dev()

David Spinadel (3):
      iwlwifi: fix scan_cmd_size allocation
      iwlwifi: disable default wildcard ssid scan
      iwlwifi: invert the order of ssid list in scan cmd

Eldad Zack (1):
      Bluetooth: bnep: use constant for ethertype

Emmanuel Grumbach (2):
      iwlwifi: don't flood logs when HT debug flag is set
      iwlwifi: don't disable AGG queues that are not enabled

Eric Lapuyade (7):
      NFC: Cache the core NFC active target pointer instead of its index
      NFC: Remove useless HCI private nfc target table
      NFC: Specify usage for targets found and target lost events
      NFC: Add HCI/SHDLC support to let driver check for tag presence
      NFC: Update Documentation/nfc-hci.txt
      NFC: HCI based pn544 driver
      NFC: HCI drivers don't have to keep track of polling state

Eyal Shapira (4):
      wlcore: add RX filters util functions
      wl12xx: add RX filters ACX commands
      wlcore: add RX filters driver state mgmt functions
      wl12xx: support wowlan wakeup patterns

Franky Lin (11):
      brcmfmac: remove unused parameter of brcmf_sdcard_reg_read
      brcmfmac: remove unused parameter of brcmf_sdcard_reg_write
      brcmfmac: decouple set_sbaddr_window from register write interface
      brcmfmac: introduce unified register access interface for SDIO
      brcmfmac: replace brcmf_sdcard_cfg_read with brcmf_sdio_regrb
      brcmfmac: replace brcmf_sdcard_cfg_write with brcmf_sdio_regwb
      brcmfmac: replace brcmf_sdcard_reg_read with brcmf_sdio_regrl
      brcmfmac: replace brcmf_sdcard_reg_write with brcmf_sdio_regwl
      brcmfmac: remove redundant retries for SDIO core register access
      brcmfmac: remove function brcmf_sdcard_regfail
      brcmfmac: replace brcmf_sdioh_card_regread with brcmf_sdio_regrl

Gustavo Padovan (13):
      Bluetooth: Remove sk parameter from l2cap_chan_create()
      Bluetooth: Remove err parameter from alloc_skb()
      Bluetooth: remove unneeded declaration of sco_conn_del()
      Bluetooth: Remove unneeded elements from size calculation
      Bluetooth: Remove hlen variable
      Merge git://git.kernel.org/.../bluetooth/bluetooth
      Bluetooth: Fix wrong set of skb fragments
      Bluetooth: Fix packet size provided to the controller
      Bluetooth: Fix skb length calculation
      Bluetooth: improve readability of l2cap_seq_list code
      Bluetooth: report the right security level in getsockopt
      Bluetooth: Create flags for bt_sk()
      Bluetooth: Report proper error number in disconnection

H Hartley Sweeten (5):
      NFC: Quiet nci/data.c sparse noise about plain integer as NULL pointer
      NFC: Include nci_core.h to nci/lib.c
      NFC: Quiet nci/ntf.c sparse noise about plain integer as NULL pointer
      NFC: HCI ops should not be exposed globally
      NFC: The NFC genl family structure should not be exposed globally

Hauke Mehrtens (32):
      ssb: remove rev from boardinfo
      MIPS: bcm47xx: refactor fetching board data
      bcma: add boardinfo struct
      MIPS: bcm47xx: read baordrev without prefix from sprom
      ssb/bcma: fill attribute alpha2 from sprom
      ssb: fill board_rev attribute from sprom
      bcma: read out some additional sprom attributes
      bcma/ssb: parse new attributes from sprom
      bcma: implement setting core clock mode to dynamic
      bcma: add bcma_core_pci_extend_L1timer
      bcma: add bcma_core_pci_fixcfg()
      bcma: add bcma_core_pci_config_fixup()
      brcmsmac: use sprom from bcma
      brcmsmac: remove brcmsmac own sprom parsing
      brcmsmac: get board and chip info from bcma
      brcmsmac: remove support for cc rev < 20
      brcmsmac: remove references to PCI
      brcmsmac: remove PCIe functions needed for PCIe core rev <=3D 10
      brcmsmac: remove pcicore_hwup()
      brcmsmac: remove ai_pci_setup()
      brcmsmac: remove ai_chipcontrl_epa4331
      brcmsmac: remove ai_gpiocontrol()
      brcmsmac: remove _ai_clkctl_cc()
      brcmsmac: remove pcicore_attach()
      brcmsmac: remove pcicore_find_pci_capability()
      brcmsmac: remove pcie_extendL1timer()
      brcmsmac: remove pcicore_fixcfg()
      brcmsmac: remove nicpci.c
      brcmsmac: do not access host_pci
      brcmsmac: read PCI vendor and device id only for PCI devices
      brcmsmac: handle non pci in ai_deviceremoved()
      ssb: add PCI IDs 0x4322 and 43222

Hemant Gupta (5):
      Bluetooth: Send correct address type for LTK
      Bluetooth: Fix clearing discovery type when stopping discovery
      Bluetooth: mgmt: Fix missing connect failed event for LE
      Bluetooth: mgmt: Fix address type while loading Long Term Key
      Bluetooth: Don't distribute keys in case of Encryption Failure

Ido Yariv (1):
      Bluetooth: Search global l2cap channels by src/dst addresses

Janusz.Dziedzic@tieto.com (1):
      mac80211: Add IV-room in the skb for TKIP and WEP

Javier Cardona (1):
      mac80211_hwsim: Fix rate control by correctly reporting transmission =
counts

Jesper Juhl (3):
      ath6kl: fix memory leak in ath6kl_fwlog_block_read()
      Bluetooth: btmrvl_sdio: remove pointless conditional before release_f=
irmware()
      wlcore: fix size of two memset's in wl1271_cmd_build_arp_rsp()

Johan Hedberg (1):
      Bluetooth: Fix Inquiry with RSSI event mask

Johannes Berg (11):
      mac80211: fix single queue drivers
      mac80211: fix TX aggregation session timer
      cfg80211: remove double prototype
      cfg80211: add warning when calculating MCS rates >=3D 32
      mac80211: (selectively) add HT details in radiotap
      nl80211: prevent additions to old station flags API
      cfg80211: fix cfg80211_can_beacon_sec_chan prototype
      nl80211: refactor valid channel type check
      iwlwifi: support explicit monitor interface
      rndis_wlan: remove set_channel cfg80211 hook
      mwifiex: remove set_channel cfg80211 hook

John W. Linville (3):
      Merge branch 'for-linville' of git://github.com/kvalo/ath6kl
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge git://git.kernel.org/.../linville/wireless-next

Jouni Malinen (2):
      ath6kl: Remove incorrect Probe Response offload support for Interwork=
ing
      ath6kl: Configure probed SSID list consistently

Kalle Valo (2):
      Merge remote branch 'wireless-next/master' into ath6kl-next
      ath6kl: merge split format strings into one

Kevin Fang (2):
      ath6kl: handle background(BK) stream properly on htc mbox layer
      ath6kl: assign Tx packet drop threshold per endpoint on htc pipe layer

Larry Finger (1):
      b43legacy: Fix error due to MMIO access with SSB unpowered

Luciano Coelho (3):
      wlcore: use GFP_KERNEL together with GFP_DMA
      wlcore: fix pointer print out in wl1271_acx_set_rx_filter()
      wlcore: fix some sparse warnings due to missing static declaration

Luis R. Rodriguez (1):
      ath6kl: include in.h explicitly

Lukasz Rymanowski (1):
      Bluetooth: Remove not needed status parameter

Marcel Holtmann (12):
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
      Bluetooth: Enable Low Energy support by default
      NFC: Select CRC_CCITT for SHDLC link layer of HCI based drivers

Mat Martineau (17):
      Bluetooth: Add definitions and struct members for new ERTM state mach=
ine
      Bluetooth: Add a structure to carry ERTM data in skb control blocks
      Bluetooth: Add the l2cap_seq_list structure for tracking frames
      Bluetooth: Functions for handling ERTM control fields
      Bluetooth: Improve ERTM sequence number offset calculation
      Bluetooth: Remove duplicate structure members from bt_skb_cb
      Bluetooth: Move recently-added ERTM header packing functions
      Bluetooth: Initialize new l2cap_chan structure members
      Bluetooth: Remove unused function
      Bluetooth: Make better use of l2cap_chan reference counting
      Bluetooth: Add Code Aurora Forum copyright
      Bluetooth: Refactor L2CAP ERTM and streaming transmit segmentation
      Bluetooth: Update tx_send_head when sending ERTM data
      Bluetooth: Initialize the transmit queue for L2CAP streaming mode
      Bluetooth: Fix a redundant and problematic incoming MTU check
      Bluetooth: Restore locking semantics when looking up L2CAP channels
      Bluetooth: Lock the L2CAP channel when sending

Michael Gruetzner (1):
      Bluetooth: Add support for Foxconn/Hon Hai AR5BBU22 0489:E03C

Mikel Astiz (3):
      Bluetooth: Use unsigned int instead of signed int
      Bluetooth: Remove unnecessary check
      Bluetooth: btusb: Dynamic alternate setting

Ming Jiang (2):
      ath6kl: allow deepsleep_suspend function when wlan interface down
      ath6kl clear the MMC_PM_KEEP_POWER for cutpower case

Nathan Hintz (6):
      bcma: Find names of non BCM cores
      bcma: Move initialization of SPROM to prevent overwrite
      bcma: Account for variable PCI memory base/size
      bcma: reads/writes are always 4 bytes, so always map 4 bytes
      bcma: Add __devexit to bcma_host_pci_remove
      bcma: Add flush for BCMA_RESET_CTL write

Naveen Gangadharan (1):
      ath6kl: Multicast filter support in wow suspend and non-suspend

Raja Mani (1):
      ath6kl: Retain bg scan period value modified by the user

Randy Dunlap (1):
      wireless: TI wlxxx depends on MAC80211

Ray Chen (2):
      ath6kl: Add AR6004 1.2 support for USB and SDIO
      ath6kl: Fix system crash sometimes for USB hotplug

Samuel Ortiz (6):
      NFC: LLCP connect must wait for a CC frame
      NFC: Update the LLCP poll mask
      NFC: Return the amount of LLCP bytes queued to sock_sendmsg
      feature-removal: Remove pn544 raw driver
      NFC: Export nfc.h to userland
      NFC: Queue I frame fragments to the LLCP sockets queue tail

Subramania Sharma Thandaveswaran (1):
      ath6kl: Fix bug in bg scan configuration in schedule scan

Sujith Manoharan (1):
      ath9k_hw: Fix RTT calibration

Syam Sidhardhan (5):
      Bluetooth: mgmt: Remove unwanted goto statements
      Bluetooth: remove header declared but not defined
      Bluetooth: Remove strtoba header declared but not defined
      Bluetooth: Remove unused hci_le_ltk_reply()
      Bluetooth: Remove unused hci_le_ltk_neg_reply()

Szymon Janc (2):
      Bluetooth: mgmt: Fix some code style and indentation issues
      Bluetooth: mgmt: Don't allow to set invalid value to DeviceID source

Thomas Pedersen (7):
      ath6kl: handle concurrent AP-STA channel switches
      ath6kl: support fw reporting phy capabilities
      ath6kl: only restore supported HT caps
      ath6kl: disallow WoW with multiple vifs
      ath6kl: unblock fwlog_block_read() on exit
      ath6kl: check for sband existence when creating scan cmd
      mac80211: send peer candidate event for new sta only

Tim Gardner (1):
      ath6kl: Normalize use of FW_DIR

Ulisses Furquim (1):
      Bluetooth: Fix registering hci with duplicate name

Vasanthakumar Thiagarajan (6):
      ath6kl: Fix possible unaligned memory access in ath6kl_get_rsn_capab()
      ath6kl: Configure 0 as rsn cap when it is not there in rsn ie
      ath6kl: Don't advertise HT capability for incapable firmware
      ath6kl: Fix bss filter setting while scanning
      ath6kl: Update netstats for some of the tx failrues in ath6kl_data_tx=
()
      ath6kl: Complete failed tx packet in ath6kl_htc_tx_from_queue()

Vinicius Costa Gomes (1):
      Bluetooth: Add support for reusing the same hci_conn for LE links

Vishal Agarwal (1):
      Bluetooth: Fix EIR data generation for mgmt_device_found

Vivek Natarajan (1):
      ath6kl_sdio: Fix the EAPOL out of order issue

Wey-Yi Guy (3):
      iwlwifi: include rssi as part of decision making for reduce txpower
      iwlwifi: add documentation for bt reduced tx power
      iwlwifi: make sure reduced tx power bit is valid

Zefir Kurtisi (1):
      nl80211: fix typos in comments

Zero.Lin (1):
      rt2x00:Add RT539b chipset support

joseph daniel (1):
      NFC: Fix LLCP compilation warning

 Documentation/feature-removal-schedule.txt         |   12 +
 Documentation/nfc/nfc-hci.txt                      |   45 +-
 arch/mips/bcm47xx/setup.c                          |   15 +-
 arch/mips/bcm47xx/sprom.c                          |   28 +-
 arch/mips/include/asm/mach-bcm47xx/bcm47xx.h       |    9 +
 drivers/bcma/core.c                                |    3 +-
 drivers/bcma/driver_pci.c                          |   53 +-
 drivers/bcma/driver_pci_host.c                     |   10 +-
 drivers/bcma/host_pci.c                            |    7 +-
 drivers/bcma/scan.c                                |   54 +-
 drivers/bcma/sprom.c                               |  149 +++-
 drivers/bluetooth/ath3k.c                          |    6 +
 drivers/bluetooth/btmrvl_drv.h                     |    3 +
 drivers/bluetooth/btmrvl_main.c                    |   56 +-
 drivers/bluetooth/btmrvl_sdio.c                    |  112 +++-
 drivers/bluetooth/btusb.c                          |   16 +-
 drivers/bluetooth/hci_ldisc.c                      |    2 +-
 drivers/bluetooth/hci_vhci.c                       |    3 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  238 ++++--
 drivers/net/wireless/ath/ath6kl/cfg80211.h         |    2 +
 drivers/net/wireless/ath/ath6kl/core.h             |   33 +-
 drivers/net/wireless/ath/ath6kl/debug.c            |   12 +-
 drivers/net/wireless/ath/ath6kl/htc_mbox.c         |   45 +-
 drivers/net/wireless/ath/ath6kl/htc_pipe.c         |   11 +-
 drivers/net/wireless/ath/ath6kl/init.c             |   29 +-
 drivers/net/wireless/ath/ath6kl/main.c             |  104 ++-
 drivers/net/wireless/ath/ath6kl/sdio.c             |   17 +-
 drivers/net/wireless/ath/ath6kl/txrx.c             |   12 +-
 drivers/net/wireless/ath/ath6kl/usb.c              |   12 +
 drivers/net/wireless/ath/ath6kl/wmi.c              |   94 ++-
 drivers/net/wireless/ath/ath6kl/wmi.h              |   24 +
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |   50 +-
 drivers/net/wireless/ath/ath9k/ar9003_mci.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_rtt.c        |   84 ++-
 drivers/net/wireless/ath/ath9k/ar9003_rtt.h        |    5 +-
 drivers/net/wireless/ath/ath9k/hw.c                |    9 +-
 drivers/net/wireless/ath/ath9k/hw.h                |    9 +-
 drivers/net/wireless/b43/bus.c                     |    6 +-
 drivers/net/wireless/b43/dma.c                     |    2 +-
 drivers/net/wireless/b43/main.c                    |    4 +-
 drivers/net/wireless/b43legacy/main.c              |    4 +-
 drivers/net/wireless/b43legacy/phy.c               |    4 +-
 drivers/net/wireless/b43legacy/radio.c             |   10 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |  244 +++---
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |   32 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  350 +++----
 .../net/wireless/brcm80211/brcmfmac/sdio_chip.c    |  265 +++---
 .../net/wireless/brcm80211/brcmfmac/sdio_host.h    |   37 +-
 drivers/net/wireless/brcm80211/brcmsmac/Makefile   |    3 -
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |  479 +---------
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.h  |   24 -
 drivers/net/wireless/brcm80211/brcmsmac/antsel.c   |   16 +-
 drivers/net/wireless/brcm80211/brcmsmac/channel.c  |    7 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   11 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  142 ++--
 drivers/net/wireless/brcm80211/brcmsmac/nicpci.c   |  826 -----------------
 drivers/net/wireless/brcm80211/brcmsmac/nicpci.h   |   77 --
 drivers/net/wireless/brcm80211/brcmsmac/otp.c      |  410 --------
 drivers/net/wireless/brcm80211/brcmsmac/otp.h      |   36 -
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |   67 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |  333 +++-----
 drivers/net/wireless/brcm80211/brcmsmac/phy_shim.c |    9 -
 drivers/net/wireless/brcm80211/brcmsmac/phy_shim.h |    3 -
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      |  228 -----
 drivers/net/wireless/brcm80211/brcmsmac/srom.c     |  980 ----------------=
----
 drivers/net/wireless/brcm80211/brcmsmac/srom.h     |   29 -
 drivers/net/wireless/brcm80211/brcmsmac/stf.c      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |   37 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |    4 +
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |   19 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |    7 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |    5 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |    8 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c            |   52 +-
 drivers/net/wireless/mac80211_hwsim.c              |    5 +
 drivers/net/wireless/mwifiex/Makefile              |    2 +
 drivers/net/wireless/mwifiex/cfg80211.c            |  498 +++++++---
 drivers/net/wireless/mwifiex/cfg80211.h            |    2 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |   21 +-
 drivers/net/wireless/mwifiex/decl.h                |   13 +-
 drivers/net/wireless/mwifiex/fw.h                  |  159 ++++-
 drivers/net/wireless/mwifiex/ie.c                  |  396 ++++++++
 drivers/net/wireless/mwifiex/init.c                |    1 +
 drivers/net/wireless/mwifiex/ioctl.h               |   32 +
 drivers/net/wireless/mwifiex/join.c                |   26 +-
 drivers/net/wireless/mwifiex/main.c                |   57 +-
 drivers/net/wireless/mwifiex/main.h                |   26 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   69 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    8 +
 drivers/net/wireless/mwifiex/sta_event.c           |   51 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    9 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |  432 +++++++++
 drivers/net/wireless/mwifiex/wmm.c                 |    4 +
 drivers/net/wireless/rndis_wlan.c                  |   14 -
 drivers/net/wireless/rt2x00/rt2800pci.c            |    1 +
 drivers/net/wireless/ti/wl12xx/Kconfig             |    1 +
 drivers/net/wireless/ti/wlcore/Kconfig             |    2 +-
 drivers/net/wireless/ti/wlcore/acx.c               |   80 ++
 drivers/net/wireless/ti/wlcore/acx.h               |   30 +
 drivers/net/wireless/ti/wlcore/boot.c              |    3 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |    8 +-
 drivers/net/wireless/ti/wlcore/event.c             |   29 +-
 drivers/net/wireless/ti/wlcore/main.c              |  323 +++++++-
 drivers/net/wireless/ti/wlcore/rx.c                |   36 +
 drivers/net/wireless/ti/wlcore/rx.h                |    4 +
 drivers/net/wireless/ti/wlcore/wl12xx.h            |   41 +
 drivers/net/wireless/ti/wlcore/wlcore.h            |    6 +
 drivers/nfc/Kconfig                                |   13 +
 drivers/nfc/Makefile                               |    1 +
 drivers/nfc/pn533.c                                |   19 +-
 drivers/nfc/pn544_hci.c                            |  947 ++++++++++++++++=
+++
 drivers/ssb/b43_pci_bridge.c                       |    2 +
 drivers/ssb/pci.c                                  |   88 ++-
 include/linux/Kbuild                               |    1 +
 include/linux/bcma/bcma.h                          |    7 +
 include/linux/bcma/bcma_driver_pci.h               |   11 +
 include/linux/nfc/pn544.h                          |    7 +
 include/linux/nl80211.h                            |    8 +-
 include/linux/ssb/ssb.h                            |    1 -
 include/linux/ssb/ssb_regs.h                       |   61 ++-
 include/net/bluetooth/bluetooth.h                  |   32 +-
 include/net/bluetooth/hci.h                        |    8 +-
 include/net/bluetooth/hci_core.h                   |   67 +-
 include/net/bluetooth/l2cap.h                      |   93 ++-
 include/net/bluetooth/mgmt.h                       |    9 +
 include/net/bluetooth/smp.h                        |    2 +-
 include/net/cfg80211.h                             |    6 +-
 include/net/mac80211.h                             |   12 +-
 include/net/nfc/hci.h                              |    6 +-
 include/net/nfc/nfc.h                              |   19 +-
 include/net/nfc/shdlc.h                            |    2 +
 net/bluetooth/af_bluetooth.c                       |    8 +-
 net/bluetooth/bnep/core.c                          |    2 +-
 net/bluetooth/hci_conn.c                           |   56 +-
 net/bluetooth/hci_core.c                           |  267 +++----
 net/bluetooth/hci_event.c                          |   75 ++-
 net/bluetooth/hci_sysfs.c                          |    5 +-
 net/bluetooth/l2cap_core.c                         |  762 +++++++++++-----
 net/bluetooth/l2cap_sock.c                         |   76 +-
 net/bluetooth/mgmt.c                               |  286 ++++---
 net/bluetooth/rfcomm/sock.c                        |   14 +-
 net/bluetooth/sco.c                                |   75 +-
 net/bluetooth/smp.c                                |    2 +-
 net/mac80211/agg-tx.c                              |   10 +-
 net/mac80211/debugfs_netdev.c                      |    2 +
 net/mac80211/ibss.c                                |    5 +
 net/mac80211/iface.c                               |    4 +-
 net/mac80211/main.c                                |    3 +
 net/mac80211/mesh.c                                |    6 +-
 net/mac80211/mesh_hwmp.c                           |    5 +-
 net/mac80211/mesh_plink.c                          |   65 +-
 net/mac80211/rx.c                                  |    6 +-
 net/mac80211/wep.c                                 |   15 +-
 net/mac80211/wpa.c                                 |   10 +-
 net/nfc/core.c                                     |  112 ++-
 net/nfc/hci/Kconfig                                |    1 +
 net/nfc/hci/core.c                                 |   78 +--
 net/nfc/hci/shdlc.c                                |   12 +
 net/nfc/llcp/commands.c                            |    4 +-
 net/nfc/llcp/llcp.c                                |    7 +
 net/nfc/llcp/sock.c                                |   57 ++-
 net/nfc/nci/core.c                                 |   27 +-
 net/nfc/nci/data.c                                 |    8 +-
 net/nfc/nci/lib.c                                  |    1 +
 net/nfc/nci/ntf.c                                  |    2 +-
 net/nfc/netlink.c                                  |    6 +-
 net/nfc/nfc.h                                      |    2 +-
 net/wireless/chan.c                                |    2 +-
 net/wireless/core.c                                |    4 +-
 net/wireless/core.h                                |    2 -
 net/wireless/nl80211.c                             |   69 +-
 net/wireless/util.c                                |    2 +-
 173 files changed, 6619 insertions(+), 5500 deletions(-)
 delete mode 100644 drivers/net/wireless/brcm80211/brcmsmac/nicpci.c
 delete mode 100644 drivers/net/wireless/brcm80211/brcmsmac/nicpci.h
 delete mode 100644 drivers/net/wireless/brcm80211/brcmsmac/otp.c
 delete mode 100644 drivers/net/wireless/brcm80211/brcmsmac/otp.h
 delete mode 100644 drivers/net/wireless/brcm80211/brcmsmac/srom.c
 delete mode 100644 drivers/net/wireless/brcm80211/brcmsmac/srom.h
 create mode 100644 drivers/net/wireless/mwifiex/ie.c
 create mode 100644 drivers/net/wireless/mwifiex/uap_cmd.c
 create mode 100644 drivers/nfc/pn544_hci.c
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--Fba/0zbH8Xs+Fj9o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPu+7LAAoJEJctW/TcYTgGa6EQAIRl01FuDMwatRRQCzRuBq8g
5RGYlbUQV22LyKE1ItkUS1NX+K2+JRTDYN83a+7l9iMC4CmUdqGiYKtIiW1o0xNK
9U2XdxA2MUB4bREijwGE6hLpPkF1tg9q3J5v/TxA5D2PCUXpjzrBnSfC+CfjJaMt
ZI4eXEo7vRawPAyLRg1H2dIZ0j93KlupLku5ILHBLE/lPtBcYBfsh+ALYztgTquw
4gecejZvrvFOhaseGtllTIirWlQphPb/txIXf4rdwRcCZ0+4ioLgRNMoNW1/0Hm9
z8SfDj+i1woMTQK4Rr6eOeJdQgxlnFDZvgh3TrWdC0Kv4nH3ZTDLZe0OYAbKQyCD
Nr4uGA4XbaMiCK/rNeh2XU4ZeVkHAbgjSvt4LsM4OJaLKxOgHJJJrUuIE0r2s2Iu
KrR4oFujJkSUxn5+stW6EPgS9Kq2dlzes7w7qIXFb2ERTkZ9NNXUB/ZM9GMrxAbA
TjKQ/ciV5QoSf4pgBYFhSwU7VObXbXHS8PMpWoiTil9u4pUcXK696PHstHjY+mRk
FmFRxkhS6fWdm3esoR8OMuM8w/XCoWWL3p5UQlxD/q1kFBTYRAs7s2GlW7kz/9e6
LnEnUQqg5PdzTjwU3qI0LwBOK5iflSmgAH8CLzIZ43pdWWGIf8o/UIkCQCXHp8rh
O6/uOVe2dWSvcJxd3qjY
=0Q/b
-----END PGP SIGNATURE-----

--Fba/0zbH8Xs+Fj9o--
