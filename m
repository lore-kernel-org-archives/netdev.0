From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-next 2012-03-09
Date: Fri, 9 Mar 2012 16:41:18 -0500
Message-ID: <20120309214118.GG2478@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="f0KYrhQ4vYSV2aJu"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: dave@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:44272 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758191Ab2CIVrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2012 16:47:11 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--f0KYrhQ4vYSV2aJu
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

commit 74dd1521d0b4f940cdd3ce7b9d988836bef589b8

Dave,

It looks like the wireless guys weren't quite done with 3.4 just yet,
so here we have another big batch of updates.  The biggest portion
of them are some iwlwifi refactoring from Johannes and the rest of
the Intel team.  The NFC guys also chime-in with some cleanups for
some style issues identified earlier.  Also included is a batch of
wl12xx updates, some ssb work from Hauke Mehrtens, a few mesh updates
=66rom Thomas and Javier, some random fixes from Dan Carpenter, and a
handful of other updates.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 2f2d76cc3e938389feee671b46252dde6880b3b7:

  dlm: Do not allocate a fd for peeloff (2012-03-08 13:52:09 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next.git =
for-davem

Amit Beka (2):
      iwlwifi: add testmode command for rx forwarding
      iwlwifi: fixed testmode notifications length

Amitkumar Karwar (4):
      mwifiex: handle auto authentication mode correctly
      mwifiex: remove unnecessary struct mwifiex_802_11_ssid
      mwifiex: fix bug in wildcard scan handling
      mwifiex: correction in number of bitrates

Arend van Spriel (9):
      brcm80211: fmac: remove unnecessary NULL pointer check
      brcm80211: fmac: remove brcmf_usb_attrib structure
      brcm80211: fmac: use counters in brcmf_bus structure
      brcm80211: fmac: initialize host interface drivers regardless result
      brcm80211: fmac: remove firmware requests from init_module syscall
      brcm80211: smac: remove firmware requests from init_module syscall
      brcm80211: smac: cleanup couple of debug output statements
      bcma: return error in bcma_sprom_get() when fallback fails
      bcma: add support for on-chip OTP memory used for SPROM storage

Arik Nemtsov (8):
      wl12xx: set the ELP entry delay to the FW dyn-ps timeout
      wl12xx: change bits in the link_map under spin lock
      wl12xx: reset link Tx queues when freeing it
      wl12xx: avoid starving the system hlid
      wl12xx: flush all Tx queues on tx_flush timeout
      wl12xx: flush Tx during suspend and 802.11h chan switch
      wl12xx: increase dynamic PS timeout to 200ms
      wl12xx: implement SW Tx watchdog

Ashok Nagarajan (2):
      {nl,cfg,mac}80211: Implement RSSI threshold for mesh peering
      mac80211: Fix potential null pointer dereferencing

Attila Fazekas (1):
      rtl8187: Add AD-HOC support

Avinash Patil (1):
      mwifiex: correct bitrates advertised to cfg80211

Christian Lamparter (2):
      p54: pass interface setup errors back to mac80211
      p54pci: use new driver.pm interface for suspend/resume

Chun-Yeow Yeoh (3):
      mac80211: Fix the generation of PREQs in proactive RANN mechanism of =
HWMP
      mac80211: fix the support of setting non-forwarding entity in Mesh
      ath5k: allow AP and mesh mode to operate simultaneously

Dan Carpenter (6):
      rndis_wlan: integer overflows in rndis_wlan_do_link_up_work()
      rndis_wlan: remove unneeded variables
      rndis_wlan: make some variables unsigned
      rndis_wlan: prevent integer overflow in indication()
      mwifiex: endian bug in mwifiex_drv_change_adhoc_chan()
      airo: fix test for FLAG_RADIO_DOWN

David Spinadel (1):
      iwlwifi: add option to test MFP

Don Fry (3):
      iwlwifi: separate status to priv and trans
      iwlwifi: more status bit factoring
      iwlwifi: correct status bit refactoring errors

Eliad Peller (11):
      wl12xx: don't start dev role on ibss vifs
      wl12xx: consider bss_conf->idle instead of hw->conf.flags
      wl12xx: implement sta_state callback
      wl12xx: set authorized AP on sta_state notification
      wl12xx: increment session_counter for device role as well
      wl12xx: set correct vif type in change_interface callback
      wl12xx: don't handle change_channel while associated
      wl12xx: don't allow scanning while device is in ROC
      wl12xx: configure the correct beacon_interval
      wl12xx: avoid bug_on_recovery during fw switch
      wl12xx: print the tx packet len

Emmanuel Grumbach (2):
      iwlwifi: log stop / wake queues
      iwlwifi: restore PAN support

Felix Fietkau (14):
      Revert "ath9k_hw: Fix false tx hung detection in AR9003 chips"
      ath9k: do not call ath9k_hw_txprocdesc on AR9003 outside of the tx ta=
sklet
      ath9k_hw: enable interrupts for beacon tx completion events
      ath9k: fix drv_tx_last_beacon on AR9003 by processing beacon tx status
      mac80211: use 16 bit alignment for the if_ibss bssid field
      mac80211: use compare_ether_addr on MAC addresses instead of memcmp
      mac80211: add an rx flag for ignoring a packet's signal strength
      ath5k: do not stop queues for full calibration
      ath5k: do not re-run AGC calibration periodically
      ath9k_hw: use cold instead of warm reset on AR9280
      ath9k: make MAC sample statistics optional
      ath9k: remove rssi/antenna information from recv debug stats
      ath9k: get rid of double queueing of rx frames on EDMA
      ath9k: fix signal strength reporting issues

Hauke Mehrtens (12):
      ssb: sprom fix some sizes / signedness
      ssb: remove 5GHz antenna gain from sprom
      ssb: fix per path sprom vars
      ssb: add alpha2
      ssb: add some missing sprom attributes
      bcma: export bcma_find_core
      bcma: add support for sprom not found on the device
      MIPS: BCM47XX: return number of written bytes in nvram_getenv
      MIPS: BCM47XX: fix signature of nvram_parse_macaddr
      MIPS: BCM47XX: move and extend sprom parsing
      MIPS: BCM47XX: provide sprom to bcma bus
      b43: prevent firmware on bcm5354 from taking over wrong GPIO pins

Javier Cardona (2):
      mac80211_hwsim: Add tsf to beacons, probe responses and radiotap head=
er.
      mac80211: Modify tsf via debugfs in mesh interfaces

Jingjun Wu (1):
      rtlwifi: rtl8192ce: Fix loss of receive performance

Johannes Berg (87):
      cfg80211: fix kernel-doc
      mac80211: use common radiotap code for cooked monitors
      mac80211: combine QoS with other BSS changes
      cfg80211/mac80211: report signal strength for mgmt frames
      iwlwifi: always monitor for stuck queues
      iwlwifi: move iwl_clear_driver_stations to user
      iwlwifi: remove an unused argument
      iwlwifi: reduce sta_lock hold time in TX
      iwlwifi: simplify code in iwlagn_key_sta_id
      iwlwifi: build some station commands directly
      iwlwifi: introduce per-queue locks
      iwlwifi: make sta lock private & BH lock
      iwlwifi: introduce statistics lock
      iwlwifi: remove shared lock
      iwlwifi: make EXIT_PENDING depend on mac80211
      iwlwifi: simplify auth/assoc flow
      iwlwifi: remove per-device debug level
      iwlwifi: remove SKU from config
      iwlwifi: use valid TX/RX antenna from hw_params
      iwlwifi: make config const
      iwlwifi: reduce IDI code ifdef
      iwlwifi: clean up (wowlan) suspend flow
      iwlwifi: move wowlan bool into priv
      iwlwifi: use ieee80211_tx_status
      iwlwifi: pass response packet directly
      iwlwifi: don't pass iwl_rx_mem_buffer to upper layers
      iwlwifi: refactor PCI-E RX path
      iwlwifi: transport's tx_agg_alloc must not sleep
      iwlwifi: move queue functions to PCI-E
      iwlwifi: iwl_rx_cmd_buffer belongs to transport API
      iwlwifi: move tid_to_ac to PCI-E
      iwlwifi: move IWL_MASK into file using it
      iwlwifi: move traffic log definitions
      iwlwifi: fix station HT parameters
      iwlwifi: move uCode deallocation to drv
      iwlwifi: move iwl_base_params to shared header
      iwlwifi: move firmware request into drv
      iwlwifi: move firmware completion wait
      iwlwifi: move ucode loading to op_mode
      iwlwifi: split out firmware store
      iwlwifi: remove iwl-wifi.h
      iwlwifi: add wrappers for command sending
      iwlwifi: move RF/CT kill check to command wrapper
      iwlwifi: move lockdep assertion into DVM
      iwlwifi: move mutex out of shared
      iwlwifi: move rfkill status handling out of transport
      iwlwifi: rename ucode.h to fw-file.h
      iwlwifi: remove AMT check from transport
      iwlwifi: remove shadow_reg_enable from hw_params
      iwlwifi: move status check functions out of shared
      iwlwifi: make tracing use device as identifier
      iwlwifi: virtualize command queue full behaviour
      iwlwifi: clean up iwl-core.h inclusions
      iwlwifi: remove num_of_queues module parameter
      iwlwifi: remove max_txq_num from hw_params
      iwlwifi: keep plcp_delta_threshold in priv
      iwlwifi: use watchdog timeout from hw_params
      iwlwifi: put use_rts_for_aggregation into hw_params
      iwlwifi: constify remaining config data
      iwlwifi: fix notification wait bug
      iwlwifi: abstract out notification wait support
      iwlwifi: move ucode_owner to priv
      iwlwifi: move all uCode load variables
      iwlwifi: move irq to PCIe
      iwlwifi: move packet to transport
      iwlwifi: virtualize nic_config
      iwlwifi: remove priv from shared
      iwlwifi: remove PA type configuration
      iwlwifi: don't include iwl-prph.h everywhere
      iwlwifi: clean up iwl-commands.h
      iwlwifi: make iwl_fill_probe_req static
      iwlwifi: remove unused arguments from iwlagn_gain_computation
      iwlwifi: remove unused argument from rs_initialize_lq
      iwlwifi: move iwl_sta_id_or_broadcast to user
      iwlwifi: remove unused argument from iwl_init_hw_rates
      iwlwifi: remove two unused arguments in testmode
      iwlwifi: remove unused argument from iwlagn_suspend
      iwlwifi: redesign PASSIVE_NO_RX workaround
      iwlwifi: transport's tx_agg_disable must be atomic
      iwlwifi: remove BT handlers from lib_ops
      iwlwifi: move BT/HT params to shared
      iwlwifi: make EEPROM enhanced TX power a bool
      iwlwifi: remove unused max_nrg_cck from sensitivity and constify
      iwlwifi: return error if loading uCode failed
      iwlwifi: remove messages from queue wake/stop
      iwlwifi: make iwl_init_context static
      iwlwifi: don't delete AP station directly

John W. Linville (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-n=
ext into for-davem

Jussi Kivilinna (3):
      rndis_wlan: fix le16/le32_to_cpu mix up with config.beacon_period
      rndis_wlan: use RNDIS_WLAN_NUM_KEYS for all key index checks
      rndis_wlan: use u8 for key indexes

Larry Finger (3):
      rtlwifi: Detect misread of end-point count
      rtlwifi: Remove extraneous value return
      rtlwifi: rtl8192c: Prevent sleeping from invalid context in rtl8192cu

Luciano Coelho (1):
      Merge branch 'wl12xx-next' into for-linville

Max Filippov (1):
      p54spi: Release GPIO lines and IRQ on error in p54spi_probe

Meenakshi Venkataraman (3):
      iwlwifi: configure transport layer from dvm op mode
      iwlwifi: move setting up fw parameters
      iwlwifi: move command queue number out of the iwl_shared struct

Mohammed Shafi Shajakhan (2):
      ath9k: completely zero intialize valid_phy_rate_idx
      ath9k: make use of list_for_each_entry_safe

Paul Stewart (1):
      mac80211: Filter duplicate IE ids

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: silence PMU warning for BCM4331

Samuel Ortiz (22):
      NFC: Export NFCID1 from pn533
      NFC: Add device powered netlink attribute
      NFC: Factorize the I frame queueing routine
      NFC: Handle Receiver Not Ready LLCP frame
      NFC: LLCP socket sendmsg implemetation
      NFC: Fix bitops usage in LLCP
      NFC: Clear pn533 target structure
      NFC: Clear LLCP SDPs whan MAC goes down
      NFC: Set the right LLCP N(R) value for I frames
      NFC: Send LLCP RR frames to acknowledge received I frames
      NFC: Set MIU and RW values from CONNECT and CC LLCP frames
      NFC: Fragment LLCP I frames
      NFC: Export sensf from pn533
      NFC: Export Jewel/Topaz ID from pn533
      NFC: Export NFCID when detecting a p2p target with pn533
      NFC: Unlink LLCP child sockets from llcp_sock_release
      NFC: SN is not an invalid GT value
      NFC: Remove the rf mode parameter from the DEP link up routine
      NFC: Fix LLCP sockets releasing path
      NFC: LLCP code identation fixes
      NFC: Core code identation fixes
      NFC: NCI code identation fixes

Simon Wunderlich (1):
      mac80211: update ieee80211_tx_rate_control kerneldoc

Stanislav Yakovlev (1):
      net/wireless: ipw2x00: remove WEXT_USECHANNELS define

Stanislaw Gruszka (7):
      iwlwifi: dump stack when fail to gain access to the device
      iwlwifi: always check if got h/w access before write
      iwlwifi: cleanup/fix memory barriers
      iwlwifi: use writeb,writel,readl directly
      iwlwifi: print DMA stop timeout error only if it happened
      iwlwifi: reintroduce iwl_enable_rfkill_int
      iwlwifi: make tx_cmd_pool kmem cache global

Thomas Pedersen (3):
      cfg80211: expose cfg80211_calculate_bitrate()
      mac80211: fix mesh airtime link metric estimating
      mac80211: fix smatch lock errors in mesh

Vasanthakumar Thiagarajan (1):
      cfg80211: Add an attribute to set inactivity timeout in AP mode

Wey-Yi Guy (2):
      iwlwifi: fix cmd_queue number merge
      iwlwifi: fix the delta for remove max_txq_num patch

 arch/mips/bcm47xx/Makefile                         |    2 +-
 arch/mips/bcm47xx/nvram.c                          |    3 +-
 arch/mips/bcm47xx/setup.c                          |  188 +----
 arch/mips/bcm47xx/sprom.c                          |  620 +++++++++++++
 arch/mips/include/asm/mach-bcm47xx/bcm47xx.h       |    3 +
 arch/mips/include/asm/mach-bcm47xx/nvram.h         |    2 +-
 drivers/bcma/driver_chipcommon_pmu.c               |    1 +
 drivers/bcma/main.c                                |    3 +-
 drivers/bcma/sprom.c                               |  182 ++++-
 drivers/net/wireless/airo.c                        |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h             |    1 +
 drivers/net/wireless/ath/ath5k/base.c              |   20 +-
 drivers/net/wireless/ath/ath5k/mac80211-ops.c      |    4 +
 drivers/net/wireless/ath/ath5k/phy.c               |   34 +-
 drivers/net/wireless/ath/ath6kl/wmi.c              |    6 +-
 drivers/net/wireless/ath/ath9k/Kconfig             |    8 +
 drivers/net/wireless/ath/ath9k/ar9003_mac.c        |   26 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |    1 -
 drivers/net/wireless/ath/ath9k/beacon.c            |    8 +-
 drivers/net/wireless/ath/ath9k/debug.c             |   41 +-
 drivers/net/wireless/ath/ath9k/debug.h             |   27 +-
 drivers/net/wireless/ath/ath9k/hw.c                |   14 +-
 drivers/net/wireless/ath/ath9k/init.c              |    4 +-
 drivers/net/wireless/ath/ath9k/mac.c               |    6 +-
 drivers/net/wireless/ath/ath9k/main.c              |    3 +-
 drivers/net/wireless/ath/ath9k/rc.c                |    2 +-
 drivers/net/wireless/ath/ath9k/rc.h                |    2 -
 drivers/net/wireless/ath/ath9k/recv.c              |   68 +-
 drivers/net/wireless/ath/ath9k/xmit.c              |    7 +-
 drivers/net/wireless/b43/main.c                    |    2 +
 drivers/net/wireless/b43legacy/phy.c               |    2 +-
 .../net/wireless/brcm80211/brcmfmac/bcmsdh_sdmmc.c |    4 +-
 drivers/net/wireless/brcm80211/brcmfmac/dhd_bus.h  |    4 +-
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |   30 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.c      |   32 +-
 drivers/net/wireless/brcm80211/brcmfmac/usb.h      |   27 +-
 drivers/net/wireless/brcm80211/brcmsmac/ampdu.c    |   20 +-
 .../net/wireless/brcm80211/brcmsmac/mac80211_if.c  |   31 +-
 drivers/net/wireless/ipw2x00/ipw2100.c             |    2 -
 drivers/net/wireless/ipw2x00/ipw2200.h             |    2 -
 drivers/net/wireless/iwlwifi/Kconfig               |   11 +-
 drivers/net/wireless/iwlwifi/Makefile              |    2 +-
 drivers/net/wireless/iwlwifi/iwl-1000.c            |   31 +-
 drivers/net/wireless/iwlwifi/iwl-2000.c            |   44 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c            |   63 +-
 drivers/net/wireless/iwlwifi/iwl-6000.c            |  103 +--
 drivers/net/wireless/iwlwifi/iwl-agn-calib.c       |   65 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c         |  101 ++-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c          |    6 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rx.c          |  180 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-rxon.c        |   91 +--
 drivers/net/wireless/iwlwifi/iwl-agn-sta.c         |  385 ++++-----
 drivers/net/wireless/iwlwifi/iwl-agn-tt.c          |   47 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c          |  164 ++--
 drivers/net/wireless/iwlwifi/iwl-agn.c             |  357 +++++---
 drivers/net/wireless/iwlwifi/iwl-agn.h             |  166 ++--
 drivers/net/wireless/iwlwifi/iwl-cfg.h             |   82 +-
 drivers/net/wireless/iwlwifi/iwl-commands.h        |  106 +---
 drivers/net/wireless/iwlwifi/iwl-core.c            |  111 +--
 drivers/net/wireless/iwlwifi/iwl-core.h            |   78 +--
 drivers/net/wireless/iwlwifi/iwl-debug.c           |    4 +-
 drivers/net/wireless/iwlwifi/iwl-debug.h           |   26 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c         |  167 ++---
 drivers/net/wireless/iwlwifi/iwl-dev.h             |   37 +-
 drivers/net/wireless/iwlwifi/iwl-devtrace.h        |  141 ++--
 drivers/net/wireless/iwlwifi/iwl-drv.c             |  684 +++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl-drv.h             |    2 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c          |   69 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |    4 +-
 .../iwlwifi/{iwl-ucode.h =3D> iwl-fw-file.h}         |   66 +--
 .../net/wireless/iwlwifi/{iwl-wifi.h =3D> iwl-fw.h}  |   97 ++-
 drivers/net/wireless/iwlwifi/iwl-io.c              |   69 +-
 drivers/net/wireless/iwlwifi/iwl-io.h              |    8 +-
 drivers/net/wireless/iwlwifi/iwl-led.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-mac80211.c        |  403 ++++-----
 drivers/net/wireless/iwlwifi/iwl-notif-wait.c      |  157 ++++
 .../iwlwifi/{iwl-trans.c =3D> iwl-notif-wait.h}      |   76 ++-
 drivers/net/wireless/iwlwifi/iwl-op-mode.h         |   26 +-
 drivers/net/wireless/iwlwifi/iwl-pci.c             |   13 +-
 drivers/net/wireless/iwlwifi/iwl-power.c           |   14 +-
 drivers/net/wireless/iwlwifi/iwl-prph.h            |    4 -
 drivers/net/wireless/iwlwifi/iwl-scan.c            |  218 +++---
 drivers/net/wireless/iwlwifi/iwl-shared.h          |  331 ++------
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |  103 ++-
 drivers/net/wireless/iwlwifi/iwl-testmode.h        |   13 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-int.h  |  104 ++-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-rx.c   |  313 ++++----
 drivers/net/wireless/iwlwifi/iwl-trans-pcie-tx.c   |  164 +++--
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |  285 +++----
 drivers/net/wireless/iwlwifi/iwl-trans.h           |  191 +++--
 drivers/net/wireless/iwlwifi/iwl-ucode.c           |  911 +++-------------=
----
 drivers/net/wireless/mac80211_hwsim.c              |   45 +-
 drivers/net/wireless/mwifiex/cfg80211.c            |   32 +-
 drivers/net/wireless/mwifiex/cmdevt.c              |    8 +-
 drivers/net/wireless/mwifiex/decl.h                |    5 -
 drivers/net/wireless/mwifiex/fw.h                  |   10 +-
 drivers/net/wireless/mwifiex/ioctl.h               |    4 +-
 drivers/net/wireless/mwifiex/join.c                |    6 +-
 drivers/net/wireless/mwifiex/main.h                |   19 +-
 drivers/net/wireless/mwifiex/scan.c                |   47 +-
 drivers/net/wireless/mwifiex/sta_event.c           |    2 +-
 drivers/net/wireless/mwifiex/sta_ioctl.c           |   20 +-
 drivers/net/wireless/p54/main.c                    |    5 +-
 drivers/net/wireless/p54/p54pci.c                  |   48 +-
 drivers/net/wireless/p54/p54spi.c                  |   14 +-
 drivers/net/wireless/rndis_wlan.c                  |   61 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c         |  110 ++-
 drivers/net/wireless/rtl818x/rtl8187/rtl8187.h     |    9 +
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |   15 +-
 drivers/net/wireless/rtlwifi/usb.c                 |   18 +-
 drivers/net/wireless/wl12xx/cmd.c                  |   26 +-
 drivers/net/wireless/wl12xx/conf.h                 |    3 +
 drivers/net/wireless/wl12xx/main.c                 |  438 ++++++----
 drivers/net/wireless/wl12xx/ps.c                   |    4 +-
 drivers/net/wireless/wl12xx/scan.c                 |    6 +
 drivers/net/wireless/wl12xx/tx.c                   |   41 +-
 drivers/net/wireless/wl12xx/tx.h                   |    1 +
 drivers/net/wireless/wl12xx/wl12xx.h               |    7 +-
 drivers/nfc/pn533.c                                |   31 +-
 drivers/ssb/pci.c                                  |   41 +-
 drivers/ssb/pcmcia.c                               |   12 +-
 drivers/ssb/sdio.c                                 |   12 +-
 include/linux/bcma/bcma.h                          |    7 +
 include/linux/bcma/bcma_driver_chipcommon.h        |   10 +-
 include/linux/nfc.h                                |    1 +
 include/linux/nl80211.h                            |   26 +-
 include/linux/ssb/ssb.h                            |  102 ++-
 include/net/cfg80211.h                             |   29 +-
 include/net/mac80211.h                             |   12 +-
 include/net/nfc/nci_core.h                         |   10 +-
 include/net/nfc/nfc.h                              |   30 +-
 net/mac80211/cfg.c                                 |   31 +-
 net/mac80211/debugfs_netdev.c                      |    9 +-
 net/mac80211/ibss.c                                |   10 +-
 net/mac80211/ieee80211_i.h                         |   46 +-
 net/mac80211/iface.c                               |    2 +-
 net/mac80211/mesh.c                                |    2 +-
 net/mac80211/mesh.h                                |    4 +
 net/mac80211/mesh_hwmp.c                           |   54 +-
 net/mac80211/mesh_pathtbl.c                        |   34 +-
 net/mac80211/mesh_plink.c                          |   17 +-
 net/mac80211/mlme.c                                |   56 +-
 net/mac80211/rx.c                                  |   70 +-
 net/mac80211/scan.c                                |   74 ++-
 net/mac80211/sta_info.c                            |    5 +-
 net/mac80211/sta_info.h                            |    6 +-
 net/mac80211/status.c                              |    3 +-
 net/mac80211/util.c                                |   46 +-
 net/nfc/af_nfc.c                                   |    2 +-
 net/nfc/core.c                                     |   50 +-
 net/nfc/llcp/commands.c                            |  163 ++++-
 net/nfc/llcp/llcp.c                                |  201 +++--
 net/nfc/llcp/llcp.h                                |   12 +-
 net/nfc/llcp/sock.c                                |  120 ++-
 net/nfc/nci/core.c                                 |  113 ++--
 net/nfc/nci/data.c                                 |   28 +-
 net/nfc/nci/ntf.c                                  |   75 +-
 net/nfc/nci/rsp.c                                  |   17 +-
 net/nfc/netlink.c                                  |   71 +-
 net/nfc/nfc.h                                      |   18 +-
 net/nfc/rawsock.c                                  |   16 +-
 net/wireless/mesh.c                                |    3 +
 net/wireless/mlme.c                                |    7 +-
 net/wireless/nl80211.c                             |   22 +-
 net/wireless/nl80211.h                             |    3 +-
 net/wireless/util.c                                |    1 +
 166 files changed, 6184 insertions(+), 4875 deletions(-)
 create mode 100644 arch/mips/bcm47xx/sprom.c
 rename drivers/net/wireless/iwlwifi/{iwl-ucode.h =3D> iwl-fw-file.h} (76%)
 rename drivers/net/wireless/iwlwifi/{iwl-wifi.h =3D> iwl-fw.h} (60%)
 create mode 100644 drivers/net/wireless/iwlwifi/iwl-notif-wait.c
 rename drivers/net/wireless/iwlwifi/{iwl-trans.c =3D> iwl-notif-wait.h} (5=
9%)
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--f0KYrhQ4vYSV2aJu
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJPWnj9AAoJEJctW/TcYTgGImsP/0cU9Encn99niGugsU/xOyF+
ti7MyzLhhrvvI6fLhUzNNJMbmkm2Z8v3fIoxikE+jXgxvX7k9QOCDL1SEOvtuby7
WtD4wZjZi49f6BpRpxWbmVhfqJcMtvu2d4ZBG7ucDQai58rFQQsdLT6YYrKo8vDu
EdxRUPThN7E1hRrD4iEVVnRzLyFpNb/AQUnCKRF9Nasq0uJgysVBZ2Vo/oA5Ba8O
Ia7/7jJtO23lFkCwsDUdRFEe+h51bs0UEqAh/yR1aU/3VDXOxw7CFuXZaHWsfW96
64ig9xGsiRZDMwco4Lyo/zOqcpAc2le2/9HGCpCfhYGo7NP/t1hhaKH+u71sB6PA
5Djr2eS7Jh84gFFSJxVP9ZpBI7SWiu2lGXVk4GVEjyJ2r/MBDlQ6YlkAQ3wKkLrg
O+JvMyAhA/b+PhBsU0eMgvxBx7MN4i1kSrIBGBT+lT40TgQS/c429Tt/Hm3nUrnd
8vpqdOQiWzoKYz/MLkqh7WZRQqgYigfqBiT/OUoTUadWRYfw/xllkIcur7xuSY9/
NU4cdrwKVyAdRIVoBLc7Cna77Xk7BckrKwRVzpzL5IRSk69LLxLbLHmBJdP7pREC
+xvD7I/gsxbpTK5WiSXL+1rAuSsiq4Rv9LHdZbiqBVRdXviaD/5lWdgLpEJPtULe
Z0RMoOPuZ3E56e0vDWaJ
=X3fE
-----END PGP SIGNATURE-----

--f0KYrhQ4vYSV2aJu--
