From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next 2013-04-10
Date: Wed, 10 Apr 2013 13:18:25 -0400
Message-ID: <20130410171825.GB15428@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="IS0zKkzwUGydFO0o"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--IS0zKkzwUGydFO0o
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please accept this pull request for the 3.10 stream...

Regarding the mac80211 bits, Johannes says:

"Here I have a bunch of minstrel fixes from Felix, per-interface
multicast filtering from Alex, set_tim debouncing from Ilan,
per-interface debugfs cleanups from Stanislaw, an error return fix from
Wei and a number of small improvements and fixes that I made myself."

And for the iwlwifi bits, Johannes says:

"Andrei changed an instance of kmalloc+memdup to kmemdup, Stanislaw
removed the now unused 5ghz_disable module parameter. I also have a
number of fixes from Ilan, Emmanuel and myself, Emmanuel also continued
working on Bluetooth coexistence."

For the sizeable batch of Bluetooth bits, Gustavo says:

"This is our first batch of patches for 3.10. The biggest changes of this p=
ull
request are from Johan Hedberg, he implemented a HCI request framework to m=
ake
life easier when we have to send many HCI commands and a block and wait for
all of the to finish, we were able to fix a few issues in stack with the
introduction of this framework.

Other than that Dean Jenkins did a good work cleaning the RFCOMM code, the
refcnt infrastructure was removed and now we use NULL pointer checks to know
when a object was freed or not. That code was buggy and now it looks a way
better.

The rest of changes are clean ups, fixes and small improvements all over the
Bluetooth subsystem."

Regarding the wl12xx bits, Luca says:

"Some patches intended for 3.10.  Mostly bug fixes and other small
improvements."

On top of that, there are updates to brcmfmac, brcmsmac, b43, ssb and
bcma, as well as mwifiex, rt2x00, and ath9k and a few others.  The most
notable bit is the addition of a new driver in the rtlwifi family.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 953c96e0d85615d1ab1f100e525d376053294dc2:

  tg3: Use bool not int (2013-04-09 17:07:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

for you to fetch changes up to d3641409a05dcb8e28116bb2ad638f5a42805d9d:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless-next into for-davem (2013-04-10 10:39:27 -0400)

----------------------------------------------------------------

Alexander Bondar (1):
      mac80211: add driver callback for per-interface multicast filter

Alexandru Gheorghiu (2):
      Bluetooth: Use PTR_RET function
      Bluetooth: Replaced kzalloc and memcpy with kmemdup

Andre Guedes (7):
      Bluetooth: Rename hci_acl_disconn
      Bluetooth: Fix __hci_req_sync
      Bluetooth: Return ENODATA in hci_req_run
      Bluetooth: Check hci_req_run returning value in __hci_req_sync
      Bluetooth: HCI request error handling
      Bluetooth: Make hci_req_add returning void
      Bluetooth: Check req->err in hci_req_add

Andreas Fenkart (4):
      mwifiex: correct wrong list in list_empty check
      mwifiex: remove unused tid_tbl_lock from mwifiex_tid_tbl
      mwifiex: fix infinite loop by removing NO_PKT_PRIO_TID
      mwifiex: hold proper locks when accessing ra_list / bss_prio lists

Andrei Epure (1):
      iwlwifi: use kmemdup instead of kmalloc+memcpy

Arend van Spriel (37):
      brcmfmac: correct success flag passed by brcmf_sdbrcm_txpkt()
      brcmfmac: minor optimization of brcmf_sdbrcm_txpkt() function
      brcmfmac: use skb_cow() in brcmf_sdbrcm_txpkt() to assure alignment
      brcmfmac: hookup firmware signalling to firmware interface events
      brcmfmac: handle firmware signal for updating mac descriptor info
      brcmfmac: add handler for credit map firmware events
      brcmfmac: add firmware-signalling cleanup function
      brcmfmac: allow stopping netif queue for different reasons
      brcmfmac: add definitions for handling sk_buff control buffer data
      brcmfmac: perform filtered firmware-signalling cleanup upon DEL_IF
      brcmfmac: add firmware-signalling hanger functions
      brcmfmac: add optional bus callback definition for tx queue cleanup
      brcmfmac: add flow-control mode to firmware signalling
      brcmfmac: enable tx status signalling
      brcmfmac: fix handling sk_buff cleanup upon bus tx failure
      brcmfmac: avoid error output in receive path
      brcmfmac: add dedicated log level for low-level sdio debugging
      brcmfmac: initialize struct brcmf_fws_info fields before iovar
      brcmfmac: correct specified length from FIFOCREDITBACK signal
      brcmfmac: move brcmf_fws_{de,}init() functions
      brcmfmac: only allocate firmware-signalling resources if required
      brcmfmac: no flow-control tlv signals when fcmode is NONE
      brcmfmac: enable sk_buff queueing when credits deplete
      brcmfmac: fix unaligned access in TXSTATUS signal handling
      brcmfmac: handle firmware signalling destination entry state
      brcmfmac: handle firmware signals requesting for packets
      brcmfmac: add hexadecimal trace of message payload
      brcmfmac: add role attribute to struct brcmf_if_event definition
      brcmfmac: remove condition for calling event handler
      brcmfmac: remove use of unconditional access of struct wireless_dev::=
netdev
      brcmfmac: use struct brcmf_if instance as parameter in brcmf_set_mpc()
      brcmfmac: use struct brcmf_if instance iso netdevice in escan functio=
ns
      brcmfmac: support creation of P2P_DEVICE through user-space
      brcmfmac: wait for firmware event when creating P2P_DEVICE interface
      brcmfmac: fix reception of P2P probe requests on P2P_DEVICE interface
      brcmfmac: obtain wdev using vif object in action frame rx
      brcmfmac: only use ifidx from BDC header in brcmf_rx_frames()

Arik Nemtsov (8):
      wlcore: fix link count in single-link-PSM optimization
      wlcore: don't risk using stale HLID during .sta_state callback
      wlcore: consolidate tx_seq handling on recovery
      wlcore: change warn on missing lock in wlcore_queue_xx funcs
      wlcore: free AP global links properly on recovery
      wlcore: AP-mode - recover security seq num for stations
      wlcore: correctly check state before regdomain conf
      wlcore: consider dummy packets when tx queues are empty

Artem Savkov (1):
      cfg80211: sched_scan_mtx lock in cfg80211_conn_work()

Avinash Patil (5):
      mwifiex: do not enable PCIe interrupt in Power Save sleep state
      mwifiex: avoid waking up device in awake state
      mwifiex: use fw_status register to wake up PCIe card
      mwifiex: change default tx/rx win_size for BA setup
      mwifiex: use separate AMPDU tx/rx window sizes in 11ac networks

Ben Greear (1):
      ath: Let user know which keycache method is complaining.

Bing Zhao (2):
      mwifiex: complete last internal scan
      mwifiex: fix negative cmd_pending count

Chen, Chien-Chia (1):
      rtlwifi: rtl8188ee: Fix wrong header patch

Christian Lamparter (1):
      carl9170: remove fast channel change feature

David Herrmann (2):
      Bluetooth: discard bt_sock_unregister() errors
      Bluetooth: change bt_sock_unregister() to return void

Dean Jenkins (6):
      Bluetooth: Avoid rfcomm_session_timeout using freed session
      Bluetooth: Check rfcomm session and DLC exists on socket close
      Bluetooth: Return RFCOMM session ptrs to avoid freed session
      Bluetooth: Remove RFCOMM session refcnt
      Bluetooth: Remove redundant call to rfcomm_send_disc
      Bluetooth: Remove redundant RFCOMM BT_CLOSED settings

Emmanuel Grumbach (8):
      iwlwifi: mvm: MVM op_mode is supported on 7000 only
      iwlwifi: mvm: fix the {ack,cts}_kill_msk
      iwlwifi: mvm: don't support multi-channel inhibition
      iwlwifi: mvm: print the flags in ALIVE notification
      iwlwifi: add debug message when a CMD is dropped in RFKILL
      iwlwifi: mvm: take the radio type / step / dash from TLVs
      iwlwifi: mvm: take the valid_{rx,tx}_ant from the TLV
      iwlwifi: mvm: tune the move to static SMPS due to BT load

Eyal Shapira (1):
      wlcore: don't attempt to roam in case of p2p

Felix Fietkau (3):
      mac80211/minstrel_ht: improve rate selection stability
      mac80211/minstrel_ht: avoid useless sampling of high-probability slow=
er rates
      mac80211/minstrel_ht: do not sample actively used rates

Franky Lin (1):
      brcmfmac: do not proceed if fail to download nvram to dongle

Gabor Juhos (4):
      rt2x00: introduce rt2x00_set_{rt,rf} helpers
      rt2x00: rt2800lib: separate RT and RF chipset detection
      rt2x00: rt2800lib: probe RT chipset earlier
      rt2x00: rt2x00pci: fix build error on Ralink RT3x5x SoCs

Hante Meuleman (4):
      brcmfmac: fix tkip mic tx/rx ap swap bug.
      brcmfmac: fix stopping AP.
      brcmfmac: fix returning cipher_suite for get_key operation.
      brcmfmac: determine the wiphy->bands property correctly.

Hauke Mehrtens (28):
      b43: use bcma_chipco_gpio_control()
      ssb: fix sprom constant for ant_available_{bg,a}
      ssb: read additional sprom v2 and v3 attributes.
      b43: remove warning for LP-PHY with sprom < 8
      b43: use constants
      brcmsmac: implement ieee80211_ops get_tsf and set_tsf
      brcmsmac: add interface type to brcms_bss_cfg
      brcmsmac: remove brcms_bss_cfg->BSS
      brcmsmac: remove brcms_bss_cfg->associated
      brcmsmac: remove brcms_bss_cfg->enable
      brcmsmac: remove brcms_bss_cfg->up
      brcmsmac: remove brcms_bss_cfg->cur_etheraddr
      brcmsmac: remove brcms_pub->bcmerr
      brcmsmac: write beacon period to hardware
      brcmsmac: add beacon template support
      brcmsmac: react on changing SSID
      brcmsmac: add support for probe response template
      brcmsmac: deactivate ucode sending probe responses
      brcmsmac: activate AP support
      brcmsmac: add support for adhoc mode
      bcma: mark eromptr as __iomem
      bcma: use BCMA_CC_PMU_CTL_* constants
      bcma: handle more devices in bcma_pmu_get_alp_clock()
      bcma: export bcma_chipco_get_alp_clock()
      bcma: export some gpio functions
      brcmsmac: remove some pmu functions and use the bcma equivalents
      b43: mark some functions and structs static
      b43: make struct b2056_inittabs_pts const

Igal Chernobelsky (2):
      wlcore: enter elp in force ps mode in 5ms
      wlcore: set max num of Rx BA sessions per chip

Ilan Peer (6):
      mac80211: Call drv_set_tim only if there is a change
      iwlwifi: mvm: Add beacon notification handler
      iwlwifi: mvm: Remove obsolete queue definitions
      iwlwifi: mvm: Fix quota handling for monitor interface
      iwlwifi: mvm: Increase the max remain on channel time
      iwlwifi: mvm: Add support for different ROC types

Joe Perches (1):
      brcmsmac: Remove unused macro SI_MSG

Johan Hedberg (38):
      Bluetooth: Rename hci_request to hci_req_sync
      Bluetooth: Fix __hci_req_sync() handling of empty requests
      Bluetooth: Split HCI init sequence into three stages
      Bluetooth: Add initial skeleton for asynchronous HCI requests
      Bluetooth: Refactor HCI command skb creation
      Bluetooth: Introduce new hci_req_add function
      Bluetooth: Fix stand-alone HCI command handling
      Bluetooth: Add request cmd_complete and cmd_status functions
      Bluetooth: Use async requests internally in hci_req_sync
      Bluetooth: Remove unused hdev->init_last_cmd
      Bluetooth: Remove empty HCI event handlers
      Bluetooth: Fix endianness handling of cmd_status/complete opcodes
      Bluetooth: Move power on HCI command updates to their own function
      Bluetooth: Update mgmt powered HCI commands to use async requests
      Bluetooth: Wait for HCI command completion with mgmt_set_powered
      Bluetooth: Fix busy condition testing for EIR and class updates
      Bluetooth: Fix UUID/class mgmt command response synchronization
      Bluetooth: Remove useless HCI_PENDING_CLASS flag
      Bluetooth: Add a define for the HCI persistent flags mask
      Bluetooth: Clear non-persistent flags when closing HCI device
      Bluetooth: Fix clearing flags on power off before notifying mgmt
      Bluetooth: Fix waiting for EIR update when setting local name
      Bluetooth: Handle AD updating through an async request
      Bluetooth: Fix local name setting for LE-only controllers
      Bluetooth: Fix setting local name to the existing value
      Bluetooth: Use an async request for mgmt_set_connectable
      Bluetooth: Fix fast connectable response sending
      Bluetooth: Limit fast connectable support to >=3D 1.2 controllers
      Bluetooth: Fix error response for simultaneous fast connectable comma=
nds
      Bluetooth: Add proper flag for fast connectable mode
      Bluetooth: Refactor fast connectable HCI commands
      Bluetooth: Disable fast connectable when disabling connectable
      Bluetooth: Add reading of page scan parameters
      Bluetooth: Update page scan parameters after successful write commands
      Bluetooth: Fix updating page scan parameters when not necessary
      Bluetooth: Fix fast connectable state when enabling page scan
      Bluetooth: Simplify address parameters of user_pairing_resp()
      Bluetooth: Fix PIN/Confirm/Passkey response parameters

Johannes Berg (14):
      mac80211: provide race-free 64-bit traffic counters
      mac80211: provide ieee80211_sta_eosp()
      mac80211: clean up key freeing a bit
      mac80211: remove underscores from some key functions
      mac80211: batch key free synchronize_net()
      mac80211: remove a few set but unused variables
      mac80211: pass queue bitmap to flush operation
      mac80211: stop queues temporarily for flushing
      mac80211_hwsim: assign CAB queue properly on interface type change
      iwlwifi: mvm: suppress key error messages in AP mode
      cfg80211: fix potential connection work crash
      iwlwifi: mvm: specify filter flags in monitor mode
      iwlwifi: mvm: fix WoWLAN RF-kill bug
      Merge remote-tracking branch 'wireless-next/master' into iwlwifi-next

John W. Linville (8):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211-ne=
xt
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-n=
ext
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth-next
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12xx
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jonas Gorski (1):
      mwl8k: always apply configuration even when device is idle

Jussi Kivilinna (4):
      rtlwifi: usb: use usb_alloc_coherent for RX buffers
      rtlwifi: usb: remove extra skb copy on RX path
      rtlwifi: usb: defer rx processing to tasklet
      rtlwifi: usb: add NET_IP_ALIGN padding to RX skb when needed

Karl Relton (1):
      Bluetooth: Make hidp_get_raw_report abort if the session is terminati=
ng

Larry Finger (11):
      rtlwifi Modify existing bits to match vendor version 2013.02.07
      rtlwifi: rtl8192se: Update driver to match vendor driver of 2013.02.07
      rtlwifi: rtl8723ae: Update to vendor driver of 2013.02.07
      rtlwifi: rtl8192c: rtl8192ce: Update to vendor driver of 2013.02.07
      rtlwifi: Rework rtl_lps_leave() and rtl_lps_enter() to use work queue
      rtlwifi: rtl8188ee: Add new driver
      rtlwifi: rtl8192c: rtl8192ce: rtl8192cu: rtl8192de: rtl8723ae: Add ch=
anges required by adding rtl81988ee
      rtlwifi: rtl8188ee: Enable recognition of RTL8188EE
      rtlwifi: rtl8188ee: Enable build of new driver
      rtlwifi: rtl8188ee: Fix linker warnings
      rtlwifi: rtl8188ee: Fix allyesconfig build failures

Li Fei (1):
      wl1251: call pm_runtime_put_sync in pm_runtime_get_sync failed case

Lubomir Rintel (1):
      bluetooth: btmrvl_sdio: look for sd8688 firmware in proper location

Luciano Coelho (3):
      wlcore: use print_hex_dump_debug()
      wlcore: move handling from hardirq to the irq thread function
      Merge branch 'wl12xx-next' into for-linville

Nadim Zubidat (1):
      wlcore: report rssi from roaming statistics

Piotr Haber (3):
      brcmfmac: avoid error output on header only packet
      brcmfmac: read firmware console without trap indication
      brcmfmac: firmware shared data version fix

Rafa=C5=82 Mi=C5=82ecki (4):
      ssb: extract board_type from SPROM
      bcma: extract board_type from SPROM
      ssb: define more board types
      bcma: define board types

Robert Shade (2):
      Show actual timeout value in failed calibration messages.
      ath9k: Re-enable interrupts after a channel change failure

Samuel Ortiz (1):
      Revert "NFC: microread: Fix MEI build failure"

Stanislaw Gruszka (3):
      mac80211: move sdata debugfs dir to vif
      mac80211: remove vif debugfs driver callbacks
      iwlwifi: remove 5ghz_disable option

Tim Gardner (1):
      rt2x00: rt2x00pci_regbusy_read() - only print register access failure=
 once

Victor Goldenshtein (1):
      wl18xx: print chip info during boot

Wei Yongjun (2):
      cfg80211: fix error return code in cfg80211_init()
      Bluetooth: fix error return code in rfcomm_add_listener()

Yogesh Ashok Powar (1):
      mwifiex: add support to configure VHT for AP mode

Zefir Kurtisi (4):
      ath9k: trivial: change spectral relayfs buffering
      ath9k: add interface combinations for DFS master
      ath9k: add debugfs based DFS radar simulation
      ath9k: add support for DFS master mode

 Documentation/DocBook/80211.tmpl                   |    2 +-
 drivers/bcma/driver_chipcommon.c                   |    5 +-
 drivers/bcma/driver_chipcommon_pmu.c               |   34 +-
 drivers/bcma/scan.c                                |   16 +-
 drivers/bcma/sprom.c                               |    1 +
 drivers/bluetooth/btmrvl_sdio.c                    |    8 +-
 drivers/net/wireless/ath/ar5523/ar5523.c           |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_calib.c      |    9 +-
 drivers/net/wireless/ath/ath9k/ar9003_calib.c      |    3 +-
 drivers/net/wireless/ath/ath9k/debug.c             |    2 +-
 drivers/net/wireless/ath/ath9k/dfs.c               |    4 +-
 drivers/net/wireless/ath/ath9k/dfs_debug.c         |   20 +
 drivers/net/wireless/ath/ath9k/hw.c                |    3 +
 drivers/net/wireless/ath/ath9k/init.c              |   36 +-
 drivers/net/wireless/ath/ath9k/main.c              |   31 +-
 drivers/net/wireless/ath/ath9k/recv.c              |    7 +
 drivers/net/wireless/ath/carl9170/carl9170.h       |    8 +-
 drivers/net/wireless/ath/carl9170/debug.c          |    2 +-
 drivers/net/wireless/ath/carl9170/main.c           |    4 +-
 drivers/net/wireless/ath/carl9170/phy.c            |   81 +-
 drivers/net/wireless/ath/key.c                     |    9 +-
 drivers/net/wireless/b43/b43.h                     |    2 +
 drivers/net/wireless/b43/main.c                    |   23 +-
 drivers/net/wireless/b43/phy_lp.c                  |   12 +-
 drivers/net/wireless/b43/phy_n.c                   |    6 +-
 drivers/net/wireless/b43/radio_2056.c              |    6 +-
 drivers/net/wireless/b43/sdio.h                    |    4 +-
 drivers/net/wireless/b43/tables_nphy.c             |    4 +-
 drivers/net/wireless/b43/tables_phy_lcn.c          |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/bcmsdh.c   |   30 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |   60 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd.h      |   33 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |   13 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_cdc.c  |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.c  |   50 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_dbg.h  |   21 +
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |  116 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |  117 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.c     |   25 +-
 drivers/net/wireless/brcm80211/brcmfmac/fweh.h     |    6 +-
 drivers/net/wireless/brcm80211/brcmfmac/fwil.c     |    1 +
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.c | 1805 +++++++++++++-
 drivers/net/wireless/brcm80211/brcmfmac/fwsignal.h |    8 +
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  190 +-
 .../net/wireless/brcm80211/brcmfmac/tracepoint.h   |   14 +
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  495 ++--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.h  |   11 +-
 drivers/net/wireless/brcm80211/brcmsmac/aiutils.c  |    6 -
 drivers/net/wireless/brcm80211/brcmsmac/d11.h      |    1 +
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   87 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |  362 ++-
 drivers/net/wireless/brcm80211/brcmsmac/main.h     |   25 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_cmn.c  |   40 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_int.h  |    1 -
 .../net/wireless/brcm80211/brcmsmac/phy/phy_lcn.c  |   35 +-
 .../net/wireless/brcm80211/brcmsmac/phy/phy_n.c    |   14 +-
 drivers/net/wireless/brcm80211/brcmsmac/pmu.c      |   54 -
 drivers/net/wireless/brcm80211/brcmsmac/pmu.h      |    6 -
 drivers/net/wireless/brcm80211/brcmsmac/pub.h      |   17 +-
 .../net/wireless/brcm80211/include/brcmu_wifi.h    |   28 +-
 drivers/net/wireless/iwlegacy/common.c             |    3 +-
 drivers/net/wireless/iwlegacy/common.h             |    2 +-
 drivers/net/wireless/iwlwifi/dvm/mac80211.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-drv.c             |    4 -
 drivers/net/wireless/iwlwifi/iwl-fw.h              |   25 +
 drivers/net/wireless/iwlwifi/iwl-modparams.h       |    2 -
 drivers/net/wireless/iwlwifi/iwl-test.c            |    3 +-
 drivers/net/wireless/iwlwifi/mvm/bt-coex.c         |   21 +-
 drivers/net/wireless/iwlwifi/mvm/d3.c              |   10 +-
 drivers/net/wireless/iwlwifi/mvm/fw-api-tx.h       |    6 +
 drivers/net/wireless/iwlwifi/mvm/fw-api.h          |   38 +-
 drivers/net/wireless/iwlwifi/mvm/fw.c              |   23 +-
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c        |   30 +-
 drivers/net/wireless/iwlwifi/mvm/mac80211.c        |   29 +-
 drivers/net/wireless/iwlwifi/mvm/mvm.h             |   15 +-
 drivers/net/wireless/iwlwifi/mvm/nvm.c             |  136 +-
 drivers/net/wireless/iwlwifi/mvm/ops.c             |   36 +-
 drivers/net/wireless/iwlwifi/mvm/phy-ctxt.c        |    7 +-
 drivers/net/wireless/iwlwifi/mvm/quota.c           |    3 +-
 drivers/net/wireless/iwlwifi/mvm/scan.c            |    4 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.c      |   38 +-
 drivers/net/wireless/iwlwifi/mvm/time-event.h      |    3 +-
 drivers/net/wireless/iwlwifi/mvm/tx.c              |   10 +-
 drivers/net/wireless/iwlwifi/pcie/tx.c             |    5 +-
 drivers/net/wireless/mac80211_hwsim.c              |    8 +-
 drivers/net/wireless/mwifiex/11ac.c                |   41 +
 drivers/net/wireless/mwifiex/11ac.h                |   17 +
 drivers/net/wireless/mwifiex/11n.c                 |   22 +
 drivers/net/wireless/mwifiex/cfg80211.c            |   12 +
 drivers/net/wireless/mwifiex/cmdevt.c              |   35 +-
 drivers/net/wireless/mwifiex/decl.h                |   11 +-
 drivers/net/wireless/mwifiex/fw.h                  |   11 +
 drivers/net/wireless/mwifiex/init.c                |    6 +-
 drivers/net/wireless/mwifiex/ioctl.h               |    8 +
 drivers/net/wireless/mwifiex/join.c                |   23 +
 drivers/net/wireless/mwifiex/main.h                |   13 +-
 drivers/net/wireless/mwifiex/pcie.c                |   47 +-
 drivers/net/wireless/mwifiex/scan.c                |   11 +-
 drivers/net/wireless/mwifiex/sta_cmd.c             |    4 +
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |    4 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |    3 -
 drivers/net/wireless/mwifiex/uap_cmd.c             |   55 +
 drivers/net/wireless/mwifiex/util.c                |    1 -
 drivers/net/wireless/mwifiex/wmm.c                 |   76 +-
 drivers/net/wireless/mwl8k.c                       |   10 +-
 drivers/net/wireless/p54/main.c                    |    2 +-
 drivers/net/wireless/rt2x00/Kconfig                |    7 +
 drivers/net/wireless/rt2x00/Makefile               |    1 +
 drivers/net/wireless/rt2x00/rt2400pci.c            |    1 +
 drivers/net/wireless/rt2x00/rt2500pci.c            |    1 +
 drivers/net/wireless/rt2x00/rt2800lib.c            |   92 +-
 drivers/net/wireless/rt2x00/rt2800pci.c            |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h               |   19 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c            |    2 +-
 drivers/net/wireless/rt2x00/rt2x00mmio.c           |  216 ++
 drivers/net/wireless/rt2x00/rt2x00mmio.h           |  119 +
 drivers/net/wireless/rt2x00/rt2x00pci.c            |  174 --
 drivers/net/wireless/rt2x00/rt2x00pci.h            |   88 -
 drivers/net/wireless/rt2x00/rt61pci.c              |    1 +
 drivers/net/wireless/rtlwifi/Kconfig               |    9 +
 drivers/net/wireless/rtlwifi/Makefile              |    1 +
 drivers/net/wireless/rtlwifi/base.c                |  379 ++-
 drivers/net/wireless/rtlwifi/base.h                |   14 +-
 drivers/net/wireless/rtlwifi/core.c                |  215 +-
 drivers/net/wireless/rtlwifi/debug.c               |    5 +-
 drivers/net/wireless/rtlwifi/debug.h               |   13 +-
 drivers/net/wireless/rtlwifi/efuse.c               |   53 +-
 drivers/net/wireless/rtlwifi/efuse.h               |    1 -
 drivers/net/wireless/rtlwifi/pci.c                 |  150 +-
 drivers/net/wireless/rtlwifi/pci.h                 |    2 +
 drivers/net/wireless/rtlwifi/ps.c                  |  330 ++-
 drivers/net/wireless/rtlwifi/ps.h                  |    2 +
 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile    |   16 +
 drivers/net/wireless/rtlwifi/rtl8188ee/def.h       |  324 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c        | 1794 ++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h        |  326 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c        |  830 +++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/fw.h        |  301 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c        | 2530 ++++++++++++++++=
++++
 drivers/net/wireless/rtlwifi/rtl8188ee/hw.h        |   68 +
 drivers/net/wireless/rtlwifi/rtl8188ee/led.c       |  157 ++
 drivers/net/wireless/rtlwifi/rtl8188ee/led.h       |   38 +
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c       | 2202 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h       |  236 ++
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c    |  109 +
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h    |  327 +++
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c |  140 ++
 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h |   97 +
 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h       | 2258 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.c        |  467 ++++
 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h        |   46 +
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c        |  400 ++++
 drivers/net/wireless/rtlwifi/rtl8188ee/sw.h        |   36 +
 drivers/net/wireless/rtlwifi/rtl8188ee/table.c     |  643 +++++
 drivers/net/wireless/rtlwifi/rtl8188ee/table.h     |   47 +
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c       |  817 +++++++
 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h       |  795 ++++++
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  101 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |   99 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.h  |    4 +
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |  118 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.h        |    4 +
 drivers/net/wireless/rtlwifi/rtl8192ce/reg.h       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |  324 +--
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   20 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   32 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |   40 +-
 drivers/net/wireless/rtlwifi/rtl8192de/reg.h       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/def.h       |    7 -
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |   49 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |  150 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.h        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   61 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.h       |    1 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |  296 +--
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |   88 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |    6 +
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |   97 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |    7 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        |   70 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c       |   22 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |   10 +-
 drivers/net/wireless/rtlwifi/usb.c                 |  220 +-
 drivers/net/wireless/rtlwifi/usb.h                 |    5 +-
 drivers/net/wireless/rtlwifi/wifi.h                |  221 +-
 drivers/net/wireless/ti/wl1251/sdio.c              |    4 +-
 drivers/net/wireless/ti/wl12xx/main.c              |    1 +
 drivers/net/wireless/ti/wl12xx/wl12xx.h            |    2 +
 drivers/net/wireless/ti/wl18xx/main.c              |   25 +-
 drivers/net/wireless/ti/wl18xx/reg.h               |   29 +
 drivers/net/wireless/ti/wl18xx/wl18xx.h            |    4 +-
 drivers/net/wireless/ti/wlcore/acx.c               |   29 +
 drivers/net/wireless/ti/wlcore/acx.h               |   16 +-
 drivers/net/wireless/ti/wlcore/cmd.c               |   32 +
 drivers/net/wireless/ti/wlcore/debug.h             |   33 +-
 drivers/net/wireless/ti/wlcore/debugfs.c           |    3 +-
 drivers/net/wireless/ti/wlcore/event.c             |    9 +-
 drivers/net/wireless/ti/wlcore/main.c              |  200 +-
 drivers/net/wireless/ti/wlcore/ps.c                |    4 +-
 drivers/net/wireless/ti/wlcore/tx.c                |   39 +-
 drivers/net/wireless/ti/wlcore/wlcore.h            |    3 +
 drivers/net/wireless/ti/wlcore/wlcore_i.h          |   29 +-
 drivers/ssb/pci.c                                  |   23 +-
 include/linux/bcma/bcma.h                          |   54 +
 include/linux/bcma/bcma_driver_chipcommon.h        |    3 +
 include/linux/ssb/ssb.h                            |   54 +-
 include/linux/ssb/ssb_regs.h                       |   10 +-
 include/net/bluetooth/bluetooth.h                  |   12 +-
 include/net/bluetooth/hci.h                        |   21 +-
 include/net/bluetooth/hci_core.h                   |   28 +-
 include/net/bluetooth/rfcomm.h                     |    6 -
 include/net/mac80211.h                             |   68 +-
 net/bluetooth/a2mp.c                               |    6 +-
 net/bluetooth/af_bluetooth.c                       |   15 +-
 net/bluetooth/bnep/sock.c                          |    4 +-
 net/bluetooth/cmtp/sock.c                          |    4 +-
 net/bluetooth/hci_conn.c                           |    4 +-
 net/bluetooth/hci_core.c                           |  727 +++++-
 net/bluetooth/hci_event.c                          |  605 +----
 net/bluetooth/hci_sock.c                           |    9 +-
 net/bluetooth/hci_sysfs.c                          |    4 +-
 net/bluetooth/hidp/core.c                          |    4 +
 net/bluetooth/hidp/sock.c                          |    4 +-
 net/bluetooth/l2cap_sock.c                         |    4 +-
 net/bluetooth/mgmt.c                               |  680 ++++--
 net/bluetooth/rfcomm/core.c                        |  167 +-
 net/bluetooth/rfcomm/sock.c                        |    3 +-
 net/bluetooth/sco.c                                |    3 +-
 net/mac80211/cfg.c                                 |   29 +-
 net/mac80211/debugfs_key.c                         |   10 +-
 net/mac80211/debugfs_netdev.c                      |   22 +-
 net/mac80211/driver-ops.h                          |   60 +-
 net/mac80211/ieee80211_i.h                         |   11 +-
 net/mac80211/iface.c                               |   17 +-
 net/mac80211/key.c                                 |  129 +-
 net/mac80211/key.h                                 |   15 +-
 net/mac80211/main.c                                |   22 +-
 net/mac80211/mesh.c                                |    5 +-
 net/mac80211/mlme.c                                |   12 +-
 net/mac80211/offchannel.c                          |    8 +-
 net/mac80211/pm.c                                  |    6 +-
 net/mac80211/rc80211_minstrel_ht.c                 |   24 +-
 net/mac80211/scan.c                                |    7 +-
 net/mac80211/sta_info.c                            |   54 +-
 net/mac80211/sta_info.h                            |    9 +-
 net/mac80211/trace.h                               |   35 +-
 net/mac80211/tx.c                                  |    8 +-
 net/mac80211/util.c                                |   48 +-
 net/wireless/core.c                                |    4 +-
 net/wireless/core.h                                |    2 -
 net/wireless/sme.c                                 |    4 +-
 258 files changed, 23446 insertions(+), 3958 deletions(-)
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00mmio.c
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00mmio.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8188ee/trx.h
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--IS0zKkzwUGydFO0o
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRZZ7hAAoJEJctW/TcYTgG0g0P/2tXXy8DQDD4p5k8Jh8w+oSN
MN3edp9E0Fm7SH4SE3YWzztumYSyDYy/aYqY9oLuxcmnonZVOqE0r2KJ+0F1rPs3
cSQDyi4xLo7/Js/BqbQj8zY5edj4hBKhhJ/hRQaJucPYe+YMxIm3QgnvgG8OcBbd
zSzkLMuxgNEkOZtKE75/DJjZKShmVwaxBocajirxrfnkvpRsY5MQD7IAzdt/9eSA
ayepxbWWVIJ8gbmCzQgeh0dtzyILbEAnO2VAp2u6Ffyo298AYF427GRoor9d9XpW
UpsmGLEOm+dNQMMyGjLiOBHKgydsH7q5kExa22FlXZuAMl1VLKjYZfhg7f8wH77n
3KDWPESoV1fSa1mkRLh14eGZeRJY+3PMF/6UxYeCo7QBWSCrpTrcRflZ+Clsy3OS
1ykzivkTYDykeDiwLZ3qT7VgzGGU/XgP/6smS3NXQokINtX7maOYkrqaDTfpuvaf
RPAYiCpmx3fT6IxZ5yMQ5BxMbCDfxeMBu2z+lup5TeU86vh24jy2UejG5wzt80ME
U77pkmc6gvTkvpSxC75OGVOMaFoeQHvNGNMwoolbxcUvFMIOPs/PYOo2EVGlMyoe
9zUoWnOBwr0nk1ws0EBQU7BWor6F7kihwJ/lgGwGA7BSBVCCU9m0nWFGP0JVHa4S
4YVA8NSvIaDG7PYVYAE7
=axcx
-----END PGP SIGNATURE-----

--IS0zKkzwUGydFO0o--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
