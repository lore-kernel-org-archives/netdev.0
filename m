From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2010-10-08
Date: Fri, 8 Oct 2010 16:10:09 -0400
Message-ID: <20101008201008.GA2414@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Another week, another huge pull request for -next...

This offering is mostly the usual driver updates and such for ath9k,
iwlwifi, rt2x00, wl1271, and a few others.  Also featured are a number
of mac80211, cfg80211 and nl80211 improvements from Johannes, as well
as some mac80211 scanning improvements from Stanislaw.  Johannes is
also sneaking a genetlink feature through this tree, of which you
are already aware. :-)

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit dd53df265b1ee7a1fbbc76bb62c3bec2383b=
bd44:

  bonding: add Speed/Duplex information to /proc/net/bonding/bond (2010=
-10-06 18:43:34 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Ben Greear (4):
      wireless: Use first phyX name available when registering phy devi=
ces.
      ath5k: Allow ath5k to support virtual STA and AP interfaces.
      ath5k: Print rx/tx bytes in debugfs
      ath9k: Report total tx/rx bytes and packets in debugfs.

Ben Hutchings (1):
      ar9170: Remove MODULE_FIRMWARE references to two-stage firmware

Bill Jordan (3):
      ath9k: add WDS interfaces to ath9k
      cfg80211: patches to allow setting the WDS peer
      mac80211: fix for WDS interfaces

Bruno Randolf (3):
      mac80211: Add WME information element for IBSS
      ath5k: Don't wake internal queues
      nl80211/mac80211: Add retry and failed transmission count to stat=
ion info

Christian Lamparter (3):
      mac80211: fix rx monitor filter refcounters
      carl9170: support firmware-based rx filter
      p54usb: add five more USBIDs

Dan Carpenter (1):
      ipw2200: check for allocation failures

=46elix Fietkau (17):
      ath9k_htc: remove use of common->ani.noise_floor
      ath9k_hw: keep calibrated noise floor values per channel
      ath9k: do not return default noise floor values via survey
      ath9k: remove the noise floor value in the ani struct
      nl80211: allow drivers to indicate whether the survey data channe=
l is in use
      ath9k: return survey data for all channels instead of just the cu=
rrent one
      ath9k: fix channel flag / regd issues with multiple cards
      ath9k_hw: remove some useless calibration data
      ath9k_hw: fix regression in ANI listen time calculation
      ath9k_hw: clean up calibration flags
      ath9k_hw: merge codepaths that access the cycle counter registers
      ath9k_hw: clean up register write buffering
      ath9k_hw: add a helper function to check for the new ANI implemen=
tation
      ath9k_hw: clean up ANI state handling
      ath9k_hw: remove code duplication in phy error counter handling
      ath9k_hw: remove function pointer abstraction for internal ANI op=
s
      ath9k_hw: merge ath9k_hw_ani_monitor_old and ath9k_hw_ani_monitor=
_new

Gabor Juhos (1):
      ath9k: get correct tx gain type in ath9k_hw_4k_get_eeprom

Helmut Schaa (18):
      rt2x00: Don't overwrite beacon buffers in pairwise key setup
      rt2x00: Split out parts of the rt2800_txdone function for easier =
reuse
      rt2x00: rework tx status handling in rt2800pci
      rt2x00: Fix SM PS check
      rt2x00: Implement HT protection for rt2800
      rt2x00: Don't initialize MM40 HT protection to RTS/CTS on PCI dev=
ices
      rt2x00: Fix race between dma mapping and clearing rx entries in r=
t2800pci
      rt2x00: Allow tx duplication for legacy rates in HT40 mode
      rt2x00: Add register definition for busy time on secondary channe=
l
      rt2x00: add field definitions for the TBTT_SYNC_CFG register
      rt2x00: Don't enable broad- and multicast buffering on USB device=
s
      mac80211: distinct between max rates and the number of rates the =
hw can report
      rt2x00: correctly set max_report_rates in rt61pci and rt2800
      rt2x00: Enable rx aggregation in rt2800
      rt2x00: Update comment about the AMPDU flag in the TXWI
      rt2x00: Fix oops caused by error path in rt2x00lib_start
      rt2x00: Improve cooperation between rt2800pci and minstrel
      rt2x00: Work around hw aggregation oddity in rt2800

Ido Yariv (3):
      wl1271: Handle large SPI transfers
      wl1271: Support firmware RX packet aggregation
      wl1271: Support firmware TX packet aggregation

Ivo van Doorn (2):
      rt2x00: Add rt73usb device ID
      rt2x00: Improve TX status entry validation

Jay Sternberg (1):
      iwlwifi: define 100 devices

Johannes Berg (17):
      cfg80211/mac80211: allow management frame TX in AP mode
      cfg80211: remove spurious __KERNEL__ ifdef
      cfg80211: fix locking
      genetlink: introduce pre_doit/post_doit hooks
      nl80211: use the new genetlink pre/post_doit hooks
      nl80211: use generic check for netif_running
      nl80211: reduce dumping boilerplate
      mac80211: fix deadlock with multiple interfaces
      nl80211: fix remain-on-channel documentation
      mac80211: delete AddBA response timer
      mac80211: avoid transmitting delBA to old AP
      cfg80211/mac80211: allow per-station GTKs
      nl80211: fix error in generic netif_running check
      cfg80211: fix BSS double-unlinking
      mac80211: fix sw scan locking
      nl80211: use new genl helpers for WDS
      cfg80211: constify WDS address

John W. Linville (9):
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'wireless-next' of git://git.kernel.org/.../luca/wl1=
2xx
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      mac80211: avoid uninitialized var warning in ieee80211_scan_cance=
l
      Revert "rtl8180: use NAPI for bottom-half processing"
      Revert "mac80211: use netif_receive_skb in ieee80211_tx_status ca=
llpath"
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-2.6
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Juuso Oikarinen (27):
      wl1271: Implement CMD_SET_STA_STATE to indicate connection comple=
tion to FW
      wl1271: Add trigger to net_device oper_state to change BT coex pr=
iority
      wl1271: Fix scan race condition
      wl1271: Change supported channel order for a more optimal scan
      wl1271: Remove outdated FIXME's
      wl1271: Move setting of wake-up conditions to ps.c from cmd.c
      wl1271: Remove acx_fw_version function
      wl1271: Release interrupt *after* releasing the driver context
      wl1271: Remove function cmd_read_memory
      wl1271: Enable/disable 11a support based on INI configuration
      wl1271: Reduce rate used for last PSM entry attempt
      wl1271: Enable 11a support always, prevent scanning for unsupport=
ing chips
      wl1271: Fix tid-configuration of TX frames
      wl1271: Fix AC/TID default configuration
      wl1271: Move scan complete invocation into work function
      wl1271: Fix work cancelling when shutting down the driver
      wl1271: Separate interface removal to another function
      wl1271: Add hardware recovery mechanism
      wl1271: Add handling for failing hardware scan command
      wl1271: Optimize scan duration
      wl1271: Increase connection reliability
      wl1271: Add support for hardware GEM cipher
      wl1271: Move work-init calls to hw allocation
      wl1271: Indicate disconnection on hardware failure
      wl1271: Add extended radio parameter initialization
      mac80211: Add validity check for beacon_crc value
      wl1271: Support FEM autodetection

Luciano Coelho (5):
      wl1271: remove deprecated ACX definition
      wl1271: remove useless 11a check when scanning
      wl1271: fix forced passive scan
      MAINTAINERS: Update git url for the wl1271 driver
      wl1271: remove deprecated __attribute__ ((packed))

Luis R. Rodriguez (1):
      mac80211: fix channel assumption for association done work

Mohammed Shafi Shajakhan (1):
      ath9k : Fix for displaying the channel number

Ohad Ben-Cohen (1):
      wl12xx: fix non-wl12xx build scenarios

Rafa=C5=82 Mi=C5=82ecki (3):
      b43: N-PHY: simplify channel switching
      b43: define B43_SHM_SH_CHAN_40MHZ
      b43: N-PHY: don't duplicate setting channel in shared memory

Rajkumar Manoharan (1):
      ath9k_hw: Fix hw reset failure with HTC driver

Senthil Balasubramanian (2):
      ath9k: remove unnecessary power save flags.
      ath9k: Introduce a wrapper for power save disable.

Shanyu Zhao (3):
      iwlwifi: add iwl_nic_ops structure to iwl_ops
      iwlagn: set CSR register for 6050g2 devices
      iwlwifi: send DC calib config to runtime ucode

Stanislaw Gruszka (8):
      iwlwifi: change WARN_ON to IWL_WARN in iwl_mac_add_interface
      mac80211: perform scan cancel in hw reset work
      mac80211: reduce number of __ieee80211_scan_completed calls
      mac80211: keep lock when calling __ieee80211_scan_completed()
      mac80211: assure we also cancel deferred scan request
      mac80211: do not requeue scan work when not needed
      mac80211: compete scan to cfg80211 if deferred scan fail to start
      Revert "iwlwifi: do not perferm force reset while doing scan"

Wey-Yi Guy (9):
      iwlagn: API v5 for 6050 series device
      iwlwifi: schedule to deprecate software scan support
      iwlagn: reduce redundant parameter definitions
      iwlagn: rename iwl5000_tx_power_dbm_cmd
      iwlwifi: remove uncorrect comments
      iwlagn: rename iwl5000_tx_resp
      iwlagn: define 130 series of WiFi/BT combo devices
      iwlagn: fix module firmware name for 130 series device
      iwlagn: add define for MODULE_FIRMWARE

ext Anand Gadiyar (1):
      omap: zoom2/3: fix build caused by wl1271 support

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2010-10-08.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
