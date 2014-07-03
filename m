From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2014-07-03
Date: Thu, 3 Jul 2014 15:12:12 -0400
Message-ID: <20140703191211.GB13303@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="tThc/1wpZn/ma/RB"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--tThc/1wpZn/ma/RB
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this first batch of wireless updates intended for the
3.17 stream...

For the mac80211 bits, Johannes says:

"The biggest thing here is probably Arik's TDLS rework, beyond that we
have smaller improvements and features like David's scanning IE thing,
Luca's queue work, some CSA work, etc. Also your PID rate control
removal, of course."

For the iwlwifi bits, Emmanuel says:

"I have here a fix from Eliad for scheduled scan: it fixes a firmware
assertion. Arik reverts a patch I made that didn't take into account
that 3160 doesn't have UAPSD and hence, we can't assume that all
newer firmwares support the feature. Here too, the visible effect
is a firmware assertion. Along with that, we have a few fixes and
additions to the device list."

On top of that, there are some cleanups to the new rsi driver, some
continuing improvements to the rtl818x drivers, and the usual bundles
of updates to ath9k, b43, mwifiex, wil6210, and a few other bits here
and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit bd4578bc84a8c8a390cf6002539e75447e78e935:

  drivers/net/hyperv/netvsc.c: remove unnecessary null test before kfree (2=
014-07-02 18:22:25 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to 63f3e836faa2e46836c324d56fe3d8fb44eb1055:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2014-07-03 14:54:42 -0400)

----------------------------------------------------------------

Alexey Khoroshilov (4):
      rsi: Use module_usb_driver
      rsi_91x_sdio: add error handling into rsi_module_init()
      rsi: GFP_ATOMIC is not needed in rsi_init_usb_interface()
      rsi: fix memory leaks and error handling in rsi_91x_usb

Amitkumar Karwar (4):
      mwifiex: add firmware dump feature for PCIe
      mwifiex: use generic 'iface_work' workqueue for SDIO interface
      mwifiex: get rid of global pointer reset_host
      mwifiex: add firmware dump feature for SDIO

Andrea Merello (10):
      rtl818x_pci: make RSSI code more readable
      rtl818x_pci: provide dBm signal information for rtl8185
      rtl818x_pci: fix possible RX descriptor invalid data read
      rtl818x_pci: Fix BSSID register written incorrectly
      rtl818x_pci: Fix rtl8185 excessive IFS after CTS-to-self
      rtl818x_pci: add comment pointing to the rtl8187se reference code
      rtl8180: fix incorrect TX retry.
      rtl8180: disable buggy rate fallback mechanism
      rtl818x_pci: handle broken PIO mapping
      rtl818x_pci: fix pci probe returns success when it fails

Andrei Otcheretianski (1):
      iwlwifi: mvm: Introduce an API to set STA_FLG_DISABLE_TX flag

Andy Lutomirski (3):
      iwlwifi: pcie: log when waking the NIC for hcmd submission fails
      iwlwifi: pcie: improve debugfs queue info
      iwlwifi: dvm: add a force_cam module parameter to fully disable power=
 saving

Antonio Ospite (1):
      trivial: net/mac80211/mesh.c: fix typo s/Substract/Subtract/

Arend van Spriel (3):
      brcmfmac: clear ht info during attach phase
      brcmfmac: correct logging levels in btcoex source
      brcmfmac: reduce log level in fwil if firmware returns error

Arik Nemtsov (10):
      mac80211: clarify TDLS Tx handling
      mac80211: set auth flags after other station info
      mac80211: cleanup TDLS state during failed setup
      cfg80211: pass TDLS initiator in tdls_mgmt operations
      mac80211: use TDLS initiator in tdls_mgmt operations
      mac80211: split tdls_mgmt function
      mac80211: implement proper Tx path flushing for TDLS
      mac80211: add API to request TDLS operation from userspace
      mac80211: make sure TDLS peer STA exists during setup
      mac80211: protect TDLS discovery session

Bing Zhao (3):
      mwifiex: wowlan: do not disconnect on suspend
      mwifiex: print sleep_confirm cmd/response and power save events
      Revert "mwifiex: Use the proper interfaces"

Bob Copeland (1):
      mac80211: remove ignore_plink_timer flag

Daniel Kim (1):
      brcmfmac: Don't control mpc setting during scan operation

David Spinadel (6):
      iwlwifi: mvm: use ksize to memset scan_command
      iwlwifi: mvm: don't use hardcoded num of scan channels
      iwlwifi: fix NVM channel attribute map.
      iwlwifi: mvm: support extended beacon notification
      mac80211: support more than one band in scan request
      mac80211: split sched scan IEs

Eliad Peller (3):
      iwlwifi: mvm: rework sched scan channel configuration
      iwlwifi: remove MCS32 support declaration
      iwlwifi: mvm: disable beacon filtering escape timer in d0i3

Emmanuel Grumbach (11):
      iwlwifi: bump API version for 8000 devices
      Merge remote-tracking branch 'iwlwifi-fixes/master' into iwlwifi-next
      iwlwifi: add device / firmware to fw-error-dump file
      iwlwifi: rename iwl_mvm_fw_error_next_data
      iwlwifi: pcie: add firmware monitor capabilities
      iwlwifi: mvm: BT Coex - allow to force the antenna allocation
      iwlwifi: mvm: BT Coex - allow MIMO in more cases
      iwlwifi: mvm: BT Coex - don't limit rate control if TTC is on
      iwlwifi: mvm: BT Coex - add reduced Tx power thresholds to constants
      iwlwifi: mvm: BT Coex - avoid the shared antenna for management frames
      iwlwivi: mvm: BT Coex - properly set the priority of beacons

Eran Harary (2):
      iwlwifi: mvm: fixes for 8000 NVM flow
      iwlwifi: mvm: fix bug in set_hw_address function

Fabian Frederick (5):
      drivers/net/wireless/rt2x00/rt2x00dev.c: remove null test before kfree
      SPECTRUM_CS: ioport_map/unmap relies on HAS_IOPORT_MAP
      LIBERTAS_CS: ioport_map/unmap relies on HAS_IOPORT_MAP
      PCMCIA_HERMES: ioport_map/unmap relies on HAS_IOPORT_MAP
      drivers/net/wireless/ipw2x00/libipw_module.c: remove unnecessary null=
 test before kfree

Felix Fietkau (22):
      ath9k: Add channel context structure
      ath9k: Move txpower limit to channel context
      ath9k: Move acq to channel context
      ath9k: Add channel context worker thread
      ath9k: channel context based transmission
      ath9k: send powersave frame on channel switch
      ath9k: Implement hw_scan support
      ath9k: Implement remain-on-channal support
      ath9k: Implement channel context ops
      ath9k: Move caldata into channel context
      ath9k: Add ATH_OP_MULTI_CHANNEL
      ath9k: save tsf in channel context
      ath9k: switch channel context for beaconing
      ath9k: Add p2p go NoA attribute
      ath9k: switch channel after sending beacon
      ath9k: Adjust AP beacon tsf based on station context
      ath9k: Implement mgd_prepare_tx
      ath9k: Add multi-channel scheduling support
      ath9k: Add periodic NoA support
      ath9k: Handle beacon miss on multi channel context
      ath9k: Update channel switch timer
      ath9k: Add recovery mechanism for hw TSF timer

Fengguang Wu (1):
      b43: b43_phyops_a can be static

Franky Lin (1):
      brcmfmac: replace cfg80211 testmode with vendor command

Hante Meuleman (3):
      brcmfmac: Add 43569 USB support.
      brcmfmac: Add USB device 43566 to supported devices.
      brcmfmac: Change USB probe routine to support Composite USB

Jahnavi Meher (18):
      rsi: Mapping the debugfs stats to the correct s/w queues.
      rsi: Fixed the kernel doc
      rsi: Using band from rsi_common to fill in ieee80211_rx_status
      rsi: Add macros for endpoints and set default value of endpoint.
      rsi: Changed the radio caps frame.
      rsi: Changed the rsi_set_channel() and rsi_program_bb_rf().
      rsi: Changed rate handling.
      rsi: Lower level debug messages and changed handling of confirm recei=
ved for rsi_program_bb_rf().
      rsi: Use SGI if configured for fixed rate transmission.
      rsi: Changed the SDIO interrupt variables and some clean up.
      rsi: Changed the logic of dequeuing packets from hal queues.
      rsi: Added debug messages.
      rsi: Sending QoS null packet via the mgmt queue.
      rsi: Adding support for 5GHz
      rsi: Adding support for host based bgscan.
      rsi: Changes for 40MHz
      rsi: Fixed errors and warnings reported by static code analyzers.
      rsi: Fixed warnings reported by static code analyzers.

Janusz Dziedzic (1):
      mac80211: allow tx via monitor iface when DFS

Joe Perches (1):
      rt2x00: Use dma_zalloc_coherent

Johannes Berg (6):
      mac80211: fix station/driver powersave race
      mac80211: remove weak WEP IV accounting
      cfg80211: make ethtool the driver's responsibility
      mac80211_hwsim: clean up own address matching
      iwlwifi: mvm: add back support for low-priority scan
      iwlwifi: mvm: handle device start failures during restart

John W. Linville (4):
      mac80211: remove PID rate control
      Merge git://git.kernel.org/.../jberg/mac80211-next
      Merge branch 'master' of git://git.kernel.org/.../iwlwifi/iwlwifi-next
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Kees Cook (1):
      rtlwifi: btcoexist: avoid format string in printk

Liad Kaufman (3):
      iwlwifi: update trans->hw_rev 8000 hw family format
      iwlwifi: nvm: update maximal parsed values in external nvm
      iwlwifi: mvm: assure no overflows occur while reading otp

Luciano Coelho (4):
      mac80211: don't stop all queues when flushing
      mac80211: introduce refcount for queue_stop_reasons
      mac80211: add functions to stop and wake all queues assigned to a vif
      mac80211: stop only the queues assigned to the vif during channel swi=
tch

Luis R. Rodriguez (1):
      p54: use request_firmware_direct() for optional EEPROM override

Markus Pargmann (1):
      mwifiex: Remove custom world regulatory domain

Mathy Vanhoef (2):
      ath5k: support for FIF_FCSFAIL filter
      ath5k: capture CCK and OFDM restarts

Michal Kazior (7):
      mac80211: move csa counters from sdata to beacon/presp
      mac80211: use csa counter offsets instead of csa_active
      mac80211: implement multi-vif in-place reservations
      mac80211: make check_combinations() aware of chanctx reservation
      mac80211: use chanctx reservation for AP CSA
      mac80211: use chanctx reservation for STA CSA
      cfg80211: remove channel_switch combination check

Peter Senna Tschudin (2):
      net: wireless: Remove useless return variables
      cw1200: Remove useless return variables

Rafa=C5=82 Mi=C5=82ecki (19):
      b43: drop B43_DEFAULT_CHANNEL
      b43: b43_op_config: drop check for core change
      b43: b43_op_config: use IEEE80211_CONF_CHANGE_CHANNEL
      b43: PHY: don't force default channel during init
      b43: b43_op_config: set channel info before switching band
      b43: store current channel using struct cfg80211_chan_def
      b43: PHY: drop own channel_freq (get it from chandef when needed)
      b43: PHY: drop is_40mhz (get width info from chandef)
      b43: PHY: drop channel_type (we can get this info from chandef)
      bcma: gpio: register all 32 GPIOs on BCM53572
      b43: remove leftover code from old devices support
      b43: add config for (en|dis)abling G-PHY support
      b43: N-PHY: update code for sending sample tone
      b43: N-PHY: update low-pass filter setup
      b43: update list and code making a selection of firmware files
      b43: treat LCNXN-PHY as extra N-PHY devices
      b43: N-PHY: fixes for radio 0x2057
      b43: N-PHY: complete generic support for 0x2057 radio
      b43: add more bcma cores

Rajkumar Manoharan (15):
      ath9k: Fetch appropriate operating channel context
      ath9k: Move beacon config to channel context
      ath9k: Summarize hw state per channel context
      ath9k: Store current offchannel duration
      ath9k: use separate HW queue for each channel context
      ath9k: Advertise multichannel support
      ath9k: Fix build error in ath_reset_internal
      ath9k_hw: update CCK loop coefficients for AR953x 1.0
      ath9k_hw: Add QCA953x 2.0 initvals
      ath9k_hw: fix XPABIASLEVEL settings for AR9531
      ath9k_hw: fix tx gain table index for AR953x
      ath9k_hw: Fix pll2_divfrac for AR953x
      ath9k: Cache beacon config after association
      ath9k: Increase max listen interval
      ath9k: Calculate sleep duration

Rasmus Villemoes (1):
      net/wireless/brcm80211/brcmfmac: Make return type and name reflect ac=
tual semantics

Rickard Strandqvist (8):
      net: wireless: libertas: cmd.c: Cleaning up uninitialized variables
      net: wireless: rt2x00: rt2x00mac.c: Cleaning up uninitialized variabl=
es
      net: wireless: rtlwifi: rtl8192de: phy.c: Cleaning up uninitialized v=
ariable
      rtlwifi/rtl8192de: Fix media status register mask
      rtlwifi/rtl8192c[eu]: Fix media status register mask
      rtlwifi/rtl8188ee: Fix media status register mask
      rtlwifi/rtl8723ae: Replace magic number by macro
      rtlwifi/rtl8723be: Replace magic number by macro

Stanislaw Gruszka (5):
      rt2x00: change beaconing locking
      rt2x00: change beaconing setup on RT2800
      rt2x00: change default MAC_BSSID_DW1_BSS_BCN_NUM
      rt2x00: change order when stop beaconing
      rt2x00: do not initialize BCN_OFFSET registers

Thomas Gleixner (4):
      mwifiex: Use the proper interfaces
      mac80211: Use ktime_get_ts()
      net: Mac80211: Remove silly timespec dance
      wireless: mwifiex: Use the proper interfaces

Vladimir Kondratiev (26):
      wil6210: Tx mgmt frame from debugfs
      wil6210: indicate mgmt_tx status
      wil6210: print debug info when starting AP
      wil6210: trace wil->status on debugfs
      wil6210: print more info about BSS found
      wil6210: more debug info for vring
      wil6210: Tx performance monitoring
      wil6210: Allow driver load if FW not ready
      wil6210: BACK: track last dropped SSN
      wil6210: debugfs interface to send raw WMI command
      wil6210: writeable ITR registers
      wil6210: print error when notifying about FW error
      wil6210: debug print when scan request state changes
      wil6210: Use "name =3D value" format in the debugfs
      wil6210: add 'freq' and 'link' debugfs entries
      wil6210: Debug print GRO Rx result
      wil6210: avoid dmesg pollution by Tx errors
      wil6210: fix disconnect handling for AP
      wil6210: remove unused #include
      wil6210: map additional registers on target
      wil6210: fix for unreachable code in wmi_recv_cmd
      wil6210: work around for platforms with broken INTx
      wil6210: add 'info' debugfs entry
      wil6210: interrupt statistics
      wil6210: track Tx queue state
      wil6210: fix for 64-bit integer division

Xinming Hu (2):
      mwifiex: add hscfg to debugfs
      mwifiex: update Copyright to 2014

Zhiyuan Yang (1):
      mwifiex: support wowlan magic-packet encapsulated as UDP packet

 MAINTAINERS                                        |  10 -
 drivers/bcma/driver_gpio.c                         |   1 +
 drivers/net/wireless/at76c50x-usb.c                |   3 +-
 drivers/net/wireless/ath/ath.h                     |   1 +
 drivers/net/wireless/ath/ath10k/mac.c              |   3 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |   1 +
 drivers/net/wireless/ath/ath5k/base.c              |  31 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |   2 +
 drivers/net/wireless/ath/ath9k/Makefile            |   3 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   3 +-
 drivers/net/wireless/ath/ath9k/ar9003_hw.c         |  15 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c        |   6 +-
 drivers/net/wireless/ath/ath9k/ar953x_initvals.h   | 201 ++++-
 drivers/net/wireless/ath/ath9k/ath9k.h             | 159 +++-
 drivers/net/wireless/ath/ath9k/beacon.c            |  97 ++-
 drivers/net/wireless/ath/ath9k/channel.c           | 685 ++++++++++++++++
 drivers/net/wireless/ath/ath9k/common-beacon.c     |   5 +-
 drivers/net/wireless/ath/ath9k/debug.c             |  28 +-
 drivers/net/wireless/ath/ath9k/hw.c                |  26 +-
 drivers/net/wireless/ath/ath9k/hw.h                |   1 +
 drivers/net/wireless/ath/ath9k/init.c              |  57 +-
 drivers/net/wireless/ath/ath9k/link.c              |   6 +-
 drivers/net/wireless/ath/ath9k/main.c              | 892 +++++++++++++++--=
----
 drivers/net/wireless/ath/ath9k/mci.c               |   4 +-
 drivers/net/wireless/ath/ath9k/pci.c               |   1 +
 drivers/net/wireless/ath/ath9k/recv.c              |  16 +-
 drivers/net/wireless/ath/ath9k/reg.h               |   4 +
 drivers/net/wireless/ath/ath9k/tx99.c              |   2 +-
 drivers/net/wireless/ath/ath9k/wow.c               |   1 +
 drivers/net/wireless/ath/ath9k/xmit.c              | 114 ++-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |  68 +-
 drivers/net/wireless/ath/wil6210/debugfs.c         | 305 ++++++-
 drivers/net/wireless/ath/wil6210/interrupt.c       |   3 +
 drivers/net/wireless/ath/wil6210/main.c            |  22 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |  31 +-
 drivers/net/wireless/ath/wil6210/rx_reorder.c      |   1 +
 drivers/net/wireless/ath/wil6210/txrx.c            |  33 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |  10 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |  40 +-
 drivers/net/wireless/b43/Kconfig                   |   9 +
 drivers/net/wireless/b43/Makefile                  |   6 +-
 drivers/net/wireless/b43/main.c                    | 300 +++----
 drivers/net/wireless/b43/phy_a.c                   |   2 +-
 drivers/net/wireless/b43/phy_a.h                   |   4 -
 drivers/net/wireless/b43/phy_common.c              |  26 +-
 drivers/net/wireless/b43/phy_common.h              |  12 +-
 drivers/net/wireless/b43/phy_ht.c                  |   2 +-
 drivers/net/wireless/b43/phy_n.c                   | 348 +++++---
 drivers/net/wireless/b43/radio_2057.c              | 122 ++-
 drivers/net/wireless/b43/radio_2057.h              |  66 ++
 drivers/net/wireless/b43/tables_nphy.c             |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/Makefile   |   3 +-
 drivers/net/wireless/brcm80211/brcmfmac/btcoex.c   |  38 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |  10 -
 .../net/wireless/brcm80211/brcmfmac/dhd_common.c   |   7 +
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |   2 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      | 214 +++--
 drivers/net/wireless/brcm80211/brcmfmac/vendor.c   | 115 +++
 drivers/net/wireless/brcm80211/brcmfmac/vendor.h   |  64 ++
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  81 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   2 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |   6 +-
 drivers/net/wireless/cw1200/scan.c                 |   3 +-
 drivers/net/wireless/cw1200/scan.h                 |   2 +-
 drivers/net/wireless/cw1200/sta.c                  |   3 +-
 drivers/net/wireless/ipw2x00/libipw_module.c       |   3 +-
 drivers/net/wireless/iwlegacy/common.c             |   3 +-
 drivers/net/wireless/iwlegacy/common.h             |   2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |   3 +-
 drivers/net/wireless/iwlwifi/dvm/power.c           |   9 +
 drivers/net/wireless/iwlwifi/iwl-8000.c            |   5 +-
 drivers/net/wireless/iwlwifi/iwl-config.h          |   2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  15 +
 drivers/net/wireless/iwlwifi/iwl-eeprom-parse.c    |   1 -
 drivers/net/wireless/iwlwifi/iwl-fw-error-dump.h   |  46 +-
 drivers/net/wireless/iwlwifi/iwl-fw-file.h         |   6 +-
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   8 +
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |   2 +
 drivers/net/wireless/iwlwifi/iwl-nvm-parse.c       |  56 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   6 +
 drivers/net/wireless/iwlwifi/mvm/coex.c            |  77 +-
 drivers/net/wireless/iwlwifi/mvm/constants.h       |   2 +
 drivers/net/wireless/iwlwifi/mvm/debugfs.c         |  39 +
 drivers/net/wireless/iwlwifi/mvm/fw-api-coex.h     |  10 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-power.h    |   2 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-scan.h     |  47 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-sta.h      |   7 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |  14 +
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |  45 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |  20 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |  16 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |  29 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |  31 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            | 142 ++--
 drivers/net/wireless/iwlwifi/mvm/sta.c             |  20 +
 drivers/net/wireless/iwlwifi/mvm/sta.h             |   2 +
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   8 +-
 drivers/net/wireless/iwlwifi/pcie/internal.h       |   7 +
 drivers/net/wireless/iwlwifi/pcie/trans.c          | 145 +++-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |   1 +
 drivers/net/wireless/libertas/Kconfig              |   2 +-
 drivers/net/wireless/libertas/cmd.c                |   1 +
 drivers/net/wireless/mac80211_hwsim.c              |  69 +-
 drivers/net/wireless/mwifiex/11ac.c                |   2 +-
 drivers/net/wireless/mwifiex/11ac.h                |   2 +-
 drivers/net/wireless/mwifiex/11h.c                 |   2 +-
 drivers/net/wireless/mwifiex/11n.c                 |   2 +-
 drivers/net/wireless/mwifiex/11n.h                 |   2 +-
 drivers/net/wireless/mwifiex/11n_aggr.c            |   2 +-
 drivers/net/wireless/mwifiex/11n_aggr.h            |   2 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   2 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.h       |   2 +-
 drivers/net/wireless/mwifiex/Makefile              |   2 +-
 drivers/net/wireless/mwifiex/README                |  32 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |  55 +-
 drivers/net/wireless/mwifiex/cfg80211.h            |   2 +-
 drivers/net/wireless/mwifiex/cfp.c                 |   2 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |  30 +-
 drivers/net/wireless/mwifiex/debugfs.c             |  95 ++-
 drivers/net/wireless/mwifiex/decl.h                |   2 +-
 drivers/net/wireless/mwifiex/ethtool.c             |  85 +-
 drivers/net/wireless/mwifiex/fw.h                  |   2 +-
 drivers/net/wireless/mwifiex/ie.c                  |   2 +-
 drivers/net/wireless/mwifiex/init.c                |  15 +-
 drivers/net/wireless/mwifiex/ioctl.h               |   2 +-
 drivers/net/wireless/mwifiex/join.c                |   2 +-
 drivers/net/wireless/mwifiex/main.c                |   8 +-
 drivers/net/wireless/mwifiex/main.h                |  34 +-
 drivers/net/wireless/mwifiex/pcie.c                | 195 ++++-
 drivers/net/wireless/mwifiex/pcie.h                |  12 +-
 drivers/net/wireless/mwifiex/scan.c                |   2 +-
 drivers/net/wireless/mwifiex/sdio.c                | 240 +++++-
 drivers/net/wireless/mwifiex/sdio.h                |  14 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |   2 +-
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   2 +-
 drivers/net/wireless/mwifiex/sta_event.c           |   2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   8 +-
 drivers/net/wireless/mwifiex/sta_rx.c              |   2 +-
 drivers/net/wireless/mwifiex/sta_tx.c              |   2 +-
 drivers/net/wireless/mwifiex/tdls.c                |   8 +-
 drivers/net/wireless/mwifiex/txrx.c                |   2 +-
 drivers/net/wireless/mwifiex/uap_cmd.c             |   2 +-
 drivers/net/wireless/mwifiex/uap_event.c           |   2 +-
 drivers/net/wireless/mwifiex/uap_txrx.c            |   6 +-
 drivers/net/wireless/mwifiex/usb.c                 |   2 +-
 drivers/net/wireless/mwifiex/usb.h                 |   2 +-
 drivers/net/wireless/mwifiex/util.c                |   2 +-
 drivers/net/wireless/mwifiex/util.h                |   2 +-
 drivers/net/wireless/mwifiex/wmm.c                 |  11 +-
 drivers/net/wireless/mwifiex/wmm.h                 |   2 +-
 drivers/net/wireless/orinoco/Kconfig               |   4 +-
 drivers/net/wireless/p54/p54spi.c                  |   2 +-
 drivers/net/wireless/rsi/rsi_91x_core.c            |  85 +-
 drivers/net/wireless/rsi/rsi_91x_debugfs.c         |  10 +-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c        | 143 +++-
 drivers/net/wireless/rsi/rsi_91x_mgmt.c            | 239 ++++--
 drivers/net/wireless/rsi/rsi_91x_pkt.c             |  17 +
 drivers/net/wireless/rsi/rsi_91x_sdio.c            |   6 +-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c        |   8 +-
 drivers/net/wireless/rsi/rsi_91x_usb.c             |  88 +-
 drivers/net/wireless/rsi/rsi_main.h                |  12 +
 drivers/net/wireless/rsi/rsi_mgmt.h                |  25 +-
 drivers/net/wireless/rsi/rsi_sdio.h                |   8 +-
 drivers/net/wireless/rt2x00/rt2800lib.c            |  69 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  10 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |  20 +-
 drivers/net/wireless/rt2x00/rt2x00mmio.c           |   8 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          |  21 +-
 drivers/net/wireless/rt2x00/rt2x00queue.h          |   1 +
 drivers/net/wireless/rtl818x/rtl8180/dev.c         |  78 +-
 drivers/net/wireless/rtl818x/rtl8180/rtl8180.h     |   1 +
 .../net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h  |   2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h       |   1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       |   1 +
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |   3 +-
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h       |   1 +
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h       |   1 +
 drivers/net/wireless/rtlwifi/rtl8723be/hw.c        |   2 +-
 drivers/net/wireless/rtlwifi/rtl8723be/reg.h       |   1 +
 drivers/net/wireless/ti/wl1251/main.c              |   3 +-
 drivers/net/wireless/ti/wl12xx/scan.c              |  20 +-
 drivers/net/wireless/ti/wl12xx/scan.h              |   2 +-
 drivers/net/wireless/ti/wl18xx/scan.c              |  16 +-
 drivers/net/wireless/ti/wl18xx/scan.h              |   2 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |  11 +-
 drivers/net/wireless/ti/wlcore/cmd.h               |   3 +-
 drivers/net/wireless/ti/wlcore/main.c              |   5 +-
 drivers/net/wireless/ti/wlcore/scan.h              |   2 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |   2 +-
 include/linux/ieee80211.h                          |   3 +
 include/net/cfg80211.h                             |  38 +-
 include/net/mac80211.h                             |  71 +-
 include/uapi/linux/nl80211.h                       |   5 +
 net/mac80211/Kconfig                               |  17 -
 net/mac80211/Makefile                              |   6 +-
 net/mac80211/agg-tx.c                              |   8 +-
 net/mac80211/cfg.c                                 | 555 +++----------
 net/mac80211/chan.c                                | 861 ++++++++++++++++-=
---
 net/mac80211/debugfs_sta.c                         |   3 +-
 net/mac80211/driver-ops.h                          |  20 +-
 net/mac80211/ethtool.c                             | 244 ++++++
 net/mac80211/ibss.c                                |   2 +-
 net/mac80211/ieee80211_i.h                         |  88 +-
 net/mac80211/iface.c                               |  13 +-
 net/mac80211/main.c                                |  10 +-
 net/mac80211/mesh.c                                |   4 +-
 net/mac80211/mesh_plink.c                          |  30 +-
 net/mac80211/mlme.c                                | 134 ++--
 net/mac80211/offchannel.c                          |   6 +-
 net/mac80211/pm.c                                  |   6 +-
 net/mac80211/rate.h                                |  13 -
 net/mac80211/rc80211_pid.h                         | 278 -------
 net/mac80211/rc80211_pid_algo.c                    | 478 -----------
 net/mac80211/rc80211_pid_debugfs.c                 | 228 ------
 net/mac80211/rx.c                                  |   2 +
 net/mac80211/scan.c                                | 118 ++-
 net/mac80211/sta_info.c                            | 201 ++++-
 net/mac80211/sta_info.h                            |  13 +-
 net/mac80211/status.c                              |   7 +-
 net/mac80211/tdls.c                                | 293 ++++++-
 net/mac80211/trace.h                               |   7 +
 net/mac80211/tx.c                                  | 170 ++--
 net/mac80211/util.c                                | 270 +++++--
 net/mac80211/wep.c                                 |  20 -
 net/wireless/core.c                                |   3 -
 net/wireless/ethtool.c                             |  86 +-
 net/wireless/ethtool.h                             |   6 -
 net/wireless/nl80211.c                             |  15 +-
 net/wireless/rdev-ops.h                            |  54 +-
 net/wireless/trace.h                               |  59 +-
 236 files changed, 7756 insertions(+), 3787 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath9k/channel.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/vendor.c
 create mode 100644 drivers/net/wireless/brcm80211/brcmfmac/vendor.h
 create mode 100644 net/mac80211/ethtool.c
 delete mode 100644 net/mac80211/rc80211_pid.h
 delete mode 100644 net/mac80211/rc80211_pid_algo.c
 delete mode 100644 net/mac80211/rc80211_pid_debugfs.c
 delete mode 100644 net/wireless/ethtool.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--tThc/1wpZn/ma/RB
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTtasLAAoJEJctW/TcYTgGl5AP/jPyFin9LbVWEmivjfiXJwkq
/D4A/RRQwnNqqz4GNHva8kSxfu13WOGnGPucKHE0xkjpM66Q9voxZNm45c6WD3M9
Mw5JaUwarZHkEi0sZUuvpt8vbzgMp+ZpvqAATrHhkMTpJzdviff5/q7M/TzqomH1
RgpLBvnf307N4es8emeKWUpCXKVeQPHztVmKRlgH1Vmz035VtH9CI7vQH69GD6Wi
V+/BsE/Be4sFiHW8E+2qOtCSSZd8Kx+tsMmxdCNM+0XsB5cz3EFhMYhaXs7En7lf
miPx1+yjwxWGHzIcttH6z5QdDlXLoUlg7d9hNDxFEEYD9W9xlm7/XhSDvFEzuIdh
m6SJo/a6Moibt1KnU7DNZO5VblWeO75tpQCy7io5tBFgmm1tJTgHjfTqat2Qpbr+
DSz04X9t3a5Mrcau+EILXOMrJW10w5Dl/yD/mdGMBpgkluKqvM6SyVh/dzzovaUz
/cwFF2mMdaBzy3vdUainFkLthQ+jJOkc7GWLQzIbPKeO+C9d1V3y0Yjbt36QsR1l
N1PFWbkIyZbLibMSTjrmNNDiF44NGY9uGocofJO6+mSJATJ3dTCkXXcI57hBkFmw
28PCBatNlJYQWz1WlB+G2J46ayejHZbZRLTys04y3mBjtat0lrN7gzavl+p2iqvy
whT8gSElUgysEBYUk7Ya
=mQ/0
-----END PGP SIGNATURE-----

--tThc/1wpZn/ma/RB--
