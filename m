From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2009-12-30
Date: Wed, 30 Dec 2009 16:10:25 -0500
Message-ID: <20091230211024.GA6706@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Here is another big set of updates intended for 2.6.34.  It is mostly
the usual stuff from the usual suspects.  But, the report below looks
kinda funny...

I had to pull wireless-2.6 into wireless-next-2.6 in order to resolve
a conflict in the libertas driver.  Since wireless-next-2.6 was cloned
from net-next-2.6 at a point before it was reopened for 2.6.34, the
pull of wireless-2.6 (which is cloned from a net-2.6 from the same
period) brought along some non-wireless bits that were not already
in wireless-next-2.6.  However, I did check and made sure that those
bits are already present in net-next-2.6.  Anyway, my point is that
I don't have enough git foo to easily generate a pull request that
represents the actual state of affairs without rebasing or doing some
other messy thing.  I think/hope this is another one-time transition
pain with the new wireless tree management policies...

So, the net of the garbled paragraph above is that despite the messy
report generatd by 'git request-pull' below, when you pull from
wireless-next-2.6 into net-next-2.6 you will only get actual wireless
changes!  I hope you can overlook the apparent discrepencies in the
report below and rely on the actual pull results instead. :-)

Please let me know if there are any problems!

Thanks,

John

---

The following changes since commit b6ce5c33001b1dc83e6a1a6f30c5dccccea6=
51b6:
  Sujith (1):
        ath9k: Fix TX poll routine

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git master

Amit Kumar Salecha (2):
      netxen: protect device reset by rtnl_lock
      netxen:fix napi intr enable check

Andrew Morton (1):
      net/rfkill/core.c: work around gcc-4.0.2 silliness

Andrey Borzenkov (1):
      orinoco: fix GFP_KERNEL in orinoco_set_key with interrupts disabl=
ed

Anton Vorontsov (1):
      gianfar: Fix build with CONFIG_NET_POLL_CONTROLLER=3Dy

Asier Llano (1):
      net/mpc5200: Fix locking on fec_mpc52xx driver

Benjamin Herrenschmidt (1):
      ps3_gelic_wireless: Fix build failure due to missing WEXT_PRIV

Benoit Papillault (1):
      ath9k: Last fix for TX software padding.

Bob Copeland (1):
      ath5k: fix SWI calibration interrupt storm

Brice Goglin (1):
      myri10ge: use src+dst for rss hashing

Bruce Allan (3):
      e1000e: minor correction to name of bit in CTRL_EXT register
      e1000e: replace incorrect use of GG82563_REG macro
      e1000e: only perform ESB2 MDIC workaround on certain configuratio=
ns

Damian Lukowski (2):
      tcp: Stalling connections: Fix timeout calculation routine
      tcp: Stalling connections: Move timeout calculation routine

Dan Carpenter (1):
      wl1271_cmd.c: cleanup char =3D> u8

Daniel Mack (1):
      Libertas: fix buffer overflow in lbs_get_essid()

David Kilroy (1):
      orinoco: remove spare KERN_DEBUG

David S. Miller (2):
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      tcp: Remove runtime check that can never be true.

Denis Kirjanov (1):
      mv643xx_eth: check for valid hw address (resubmit)

Dhananjay Phadke (1):
      netxen: fix firmware type check

Don Skidmore (1):
      ixgbe: add support for 82599 KR device 0x1517

Eric Dumazet (4):
      ixgbe: Fix TX stats accounting
      tcp: Fix a connect() race with timewait sockets
      tcp: Fix a connect() race with timewait sockets
      tcp: documents timewait refcnt tricks

=46elix Fietkau (3):
      ath9k: fix tx status reporting
      mac80211: fix ibss join with fixed-bssid
      ath9k: fix missed error codes in the tx status check

Gertjan van Wingerde (9):
      rt2x00: Fix rt2800usb detection in rt2800lib.
      mac80211: Add define for TX headroom reserved by mac80211 itself.
      rt2x00: Disable powersaving for rt61pci and rt2800pci.
      rt2x00: Fix calculation of rt2800 iveiv entry offset.
      rt2x00: Add USB ID for Linksys WUSB 600N rev 2.
      rt2x00: Fix checks for rt2800 SOC support.
      rt2x00: Let rt2800lib check CONFIG_RT2X00_LIB_USB instead of CONF=
IG_RT2800USB
      rt2x00: convert RT2800PCI_PCI and RT2800PCI_SOC Kconfig symbols t=
o booleans.
      rt2x00: Cleanup chip handling helper functions.

Herton Ronaldo Krzesinski (1):
      rtl8187: add radio led and fix warnings on suspend

Ilpo J=E4rvinen (1):
      tcp: fix retrans_stamp advancing in error cases

Javier Cardona (2):
      mac80211: Fixed bug in mesh portal paths
      mac80211: Revert 'Use correct sign for mesh active path refresh'

Jie Yang (2):
      atl1c:add pci map direction in atl1c_buffer flags
      atl1c:use common_task instead of reset_task and link_chg_task

Joe Perches (1):
      include/linux/if_ether.h: Remove unused defines MAC_BUF_SIZE and =
DECLARE_MAC_BUF

Johannes Berg (22):
      mac80211: recalculate idle later in MLME
      iwlwifi: fix EEPROM/OTP reading endian annotations and a bug
      iwlwifi: fix more eeprom endian bugs
      mac80211: fix peer HT capabilities
      mac80211: fix WMM AP settings application
      wireless: remove remaining qual code
      cfg80211: fix race between deauth and assoc response
      cfg80211: fix error path in cfg80211_wext_siwscan
      mac80211: add ieee80211_sdata_running
      mac80211: introduce flush operation
      mac80211: let cfg80211 manage auth state
      mac80211: generalise management work a bit
      mac80211: generalise work handling
      mac80211: rewrite a few work messages
      mac80211: refactor association
      mac80211: split up and insert custom IEs correctly
      mac80211: proper bss private data handling
      mac80211: support remain-on-channel command
      mac80211: make off-channel work generic
      mac80211/cfg80211: add station events
      mac80211: remove struct ieee80211_if_init_conf
      mac80211: remove requeue from work

John W. Linville (9):
      iwlwifi: fix warning from ieee80211_stop_tx_ba_cb_irqsafe argumen=
t change
      wireless: correctly report signal value for IEEE80211_HW_SIGNAL_U=
NSPEC
      wireless: update old static regulatory domain rules
      Merge git://git.kernel.org/.../linville/wireless-2.6
      wireless: remove CONFIG_WIRELESS_OLD_REGULATORY
      rtl8180: remove priv->mode
      rtl8187: remove priv->mode
      Revert "b43: Enforce DMA descriptor memory constraints"
      Merge git://git.kernel.org/.../linville/wireless-2.6

Jouni Malinen (2):
      mac80211: Generalize off-channel operation helpers from scan code
      cfg80211: add remain-on-channel command

Julia Lawall (2):
      net/mac80211: Correct size given to memset
      drivers/net/wireless: Correct code taking the size of a pointer

Juuso Oikarinen (15):
      wl1271: Configure smart-reflex paramter values.
      wl1271: Remove smart reflex ACX
      wl1271: Use slow rates for association messages
      wl1271: Fix event acknowledging functionality
      wl1271: prevent power save entry while not associated
      wl1271: Implement chipset boot retry
      wl1271: Add pre-power-on sleep
      wl1271: Remove beacon-loss-ind from PSM entry failure handling
      wl1271: Add rudimentary ad-hoc support
      wl1271: Change rates configured for templates
      wl1271: Fix supported rate management
      wl1271: Change booleans in struct wl1271 into a flags bitmask
      wl1271: Add support for acx_pm_config
      wl1271: Check vif for NULL when indicating beacon-loss
      wl1271: Prevent performing "join" before association

Kalle Valo (4):
      wl1251: remove false warning messages
      wl1251: fix bssid handling
      wl1251: don't build null data template in wl1251_op_config()
      mac80211: annotate sleeping driver ops

Larry Finger (3):
      rtl8187: Fix wrong rfkill switch mask for some models
      b43: Remove reset after fatal DMA error
      b43: Allow PIO mode to be selected at module load

Lennert Buytenhek (23):
      mwl8k: fix MCS bitmap size in SET_RATE command
      mwl8k: fix UPDATE_STADB command struct legacy_rates array length
      mwl8k: prevent corruption of QoS field on receive
      mwl8k: fix addr4 zeroing and payload overwrite on DMA header crea=
tion
      mwl8k: properly report rate on received 40MHz packets
      mwl8k: allow more time for firmware commands to complete
      mwl8k: allow more time for transmit rings to drain
      mwl8k: increase firmware loading timeouts
      mwl8k: don't forget to call pci_disable_device()
      mwl8k: struct ieee80211_rx_status::qual is deprecated
      mwl8k: don't overwrite mwl8k_vif::bssid until after disassociatio=
n
      mwl8k: don't complain about oversized beacons in FINALIZE_JOIN
      mwl8k: firmware command code cleanup
      mwl8k: hw is never NULL in mwl8k_set_radio_preamble()
      mwl8k: get rid of the AMSDU check in the transmit path
      mwl8k: inline qos field manipulation functions
      mwl8k: initialize the mwl8k_info_tbl table using the MWL* enums
      mwl8k: add 2.4GHz channels 12, 13 and 14
      mwl8k: get rid of the struct mwl8k_firmware abstraction
      mwl8k: do rx/tx ring initialisation after loading firmware
      mwl8k: fix up AP vs. STA firmware image receive descriptor handli=
ng
      mwl8k: remove unused mwl8k_vif::priv
      mwl8k: remove duplicate local per-vif copy of ieee80211_bss_conf

Luciano Coelho (16):
      wl1271: updated radio parameters structure for newer firmwares
      wl1271: updated general parameters structure for newer firmwares
      wl1271: update radio and general parameters values
      wl1271: added radio parameters configuration values newer firmwar=
es
      wl1271: use join command with dummy BSSID
      wl1271: remove workaround for disconnection
      wl1271: limit TX power to 25dBm for every channel
      wl1271: check result code from the join command
      wl1271: set null data template when BSSID is known
      wl1271: use the correct macro when setting the basic rates
      wl1271: implement dco itrim parameters setting
      wl1271: fix one typo in the rx_rssi_and_proc_compens values
      wl1271: add gpio_power file in debugfs to power the chip on and o=
ff
      wl1271: upload only the first 468 bytes from the NVS file
      wl1271: some new configuration values according to new reference
      wl1271: use channel 1 when configuring the data path

Luis R. Rodriguez (5):
      ath5k: enable EEPROM checksum check
      ath9k: wake hardware for interface IBSS/AP/Mesh removal
      ath9k: wake hardware during AMPDU TX actions
      mac80211: fix race with suspend and dynamic_ps_disable_work
      mac80211: fix propagation of failed hardware reconfigurations

Reinette Chatre (4):
      iwlwifi: power up all devices for EEPROM read
      iwl3945: disable power save
      iwlwifi: initialize spinlock before use
      iwlwifi: fix 40MHz operation setting on cards that do not allow i=
t

Roel Kluin (2):
      iwmc3200wifi: Fix test of unsigned in iwm_ntf_stop_resume_tx()
      wl1251: timeout one too soon in wl1251_boot_run_firmware()

Samuel Ortiz (1):
      libertas: Remove carrier signaling from the scan code

Shahar Or (1):
      ath5k: add support for Dell Vostro A860 LED

Stanislav Brabec (1):
      b44 WOL setup: one-bit-off stack corruption kernel panic fix

Sujith (4):
      ath9k: Fix bug in assigning sequence number
      ath9k: Fix TX queue draining
      ath9k: Stop ANI when doing a reset
      ath9k: fix suspend by waking device prior to stop

Tilman Schmidt (2):
      gigaset: don't enable any debugging output by default
      gigaset: documentation amendments

Tobias Klauser (2):
      ath9k: Storage class should be before const qualifier
      iwlwifi: Storage class should be before const qualifier

Vasanthakumar Thiagarajan (1):
      mac80211: Fix bug in computing crc over dynamic IEs in beacon

Vivek Natarajan (2):
      mac80211: Fix dynamic power save for scanning.
      cfg80211: Clear encryption privacy when key off is done.

Wey-Yi Guy (1):
      iwlwifi: fix syslog message for event log dump size

Zhu Yi (3):
      iwlwifi: allocated rx page accounting cleanup
      iwl3945: fix panic in iwl3945 driver
      iwmc3200wifi: fix array out-of-boundary access

akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org (1):
      drivers/net/wireless/iwlwifi/iwl-tx.c: fix gcc-3.4.5 warning

chas williams - CONTRACTOR (3):
      atm: [lec] initialize .netdev_ops before calling register_netdev(=
)
      atm: [he] adjust tests to account for sk_wmem_alloc changes
      atm: [br2684] allow routed mode operation again

 Documentation/feature-removal-schedule.txt    |   21 -
 Documentation/isdn/README.gigaset             |  116 ++-
 drivers/atm/he.c                              |    4 +-
 drivers/isdn/gigaset/common.c                 |    2 +-
 drivers/net/Kconfig                           |    2 +
 drivers/net/atl1c/atl1c.h                     |   17 +-
 drivers/net/atl1c/atl1c_main.c                |   94 +-
 drivers/net/b44.c                             |    3 +-
 drivers/net/e1000e/defines.h                  |    2 +-
 drivers/net/e1000e/es2lan.c                   |   97 ++-
 drivers/net/e1000e/hw.h                       |    7 +
 drivers/net/e1000e/ich8lan.c                  |    8 +-
 drivers/net/e1000e/netdev.c                   |    2 +-
 drivers/net/fec_mpc52xx.c                     |  121 ++--
 drivers/net/gianfar.c                         |    1 +
 drivers/net/ixgbe/ixgbe_82599.c               |    1 +
 drivers/net/ixgbe/ixgbe_ethtool.c             |    1 +
 drivers/net/ixgbe/ixgbe_main.c                |   22 +-
 drivers/net/ixgbe/ixgbe_type.h                |    1 +
 drivers/net/mv643xx_eth.c                     |    3 +
 drivers/net/myri10ge/myri10ge.c               |    4 +-
 drivers/net/netxen/netxen_nic_init.c          |   14 +-
 drivers/net/netxen/netxen_nic_main.c          |   49 +-
 drivers/net/wireless/adm8211.c                |   12 +-
 drivers/net/wireless/at76c50x-usb.c           |    6 +-
 drivers/net/wireless/ath/ar9170/main.c        |    8 +-
 drivers/net/wireless/ath/ath5k/base.c         |   36 +-
 drivers/net/wireless/ath/ath5k/eeprom.c       |    3 +-
 drivers/net/wireless/ath/ath5k/led.c          |    2 +
 drivers/net/wireless/ath/ath9k/mac.c          |    2 +-
 drivers/net/wireless/ath/ath9k/mac.h          |    3 +
 drivers/net/wireless/ath/ath9k/main.c         |   48 +-
 drivers/net/wireless/ath/ath9k/pci.c          |    2 +-
 drivers/net/wireless/ath/ath9k/xmit.c         |   42 +-
 drivers/net/wireless/b43/Kconfig              |   17 +-
 drivers/net/wireless/b43/Makefile             |    2 +-
 drivers/net/wireless/b43/b43.h                |   13 -
 drivers/net/wireless/b43/dma.c                |  199 +---
 drivers/net/wireless/b43/dma.h                |    7 +-
 drivers/net/wireless/b43/main.c               |   36 +-
 drivers/net/wireless/b43/pio.h                |   40 -
 drivers/net/wireless/b43legacy/main.c         |   24 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c       |   15 +-
 drivers/net/wireless/iwlwifi/iwl-3945.h       |    1 -
 drivers/net/wireless/iwlwifi/iwl-4965.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000-hw.h    |   14 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c       |    7 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c     |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c        |    6 +-
 drivers/net/wireless/iwlwifi/iwl-core.c       |   20 +-
 drivers/net/wireless/iwlwifi/iwl-core.h       |    4 +-
 drivers/net/wireless/iwlwifi/iwl-csr.h        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h        |   13 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.c     |   37 +-
 drivers/net/wireless/iwlwifi/iwl-eeprom.h     |    4 +-
 drivers/net/wireless/iwlwifi/iwl-hcmd.c       |    2 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c         |   56 +-
 drivers/net/wireless/iwlwifi/iwl-scan.c       |    3 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c        |    8 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c         |    5 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c   |   68 +-
 drivers/net/wireless/iwmc3200wifi/iwm.h       |    4 +-
 drivers/net/wireless/iwmc3200wifi/netdev.c    |    2 +-
 drivers/net/wireless/iwmc3200wifi/rx.c        |    2 +-
 drivers/net/wireless/libertas/scan.c          |   22 +-
 drivers/net/wireless/libertas/wext.c          |    2 -
 drivers/net/wireless/libertas_tf/main.c       |   11 +-
 drivers/net/wireless/mac80211_hwsim.c         |   29 +-
 drivers/net/wireless/mwl8k.c                  | 1283 ++++++++++++-----=
--------
 drivers/net/wireless/orinoco/hermes_dld.c     |    2 +-
 drivers/net/wireless/orinoco/wext.c           |    6 +-
 drivers/net/wireless/p54/main.c               |   12 +-
 drivers/net/wireless/rt2x00/Kconfig           |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c       |    5 +-
 drivers/net/wireless/rt2x00/rt2500pci.c       |   39 +-
 drivers/net/wireless/rt2x00/rt2500usb.c       |   38 +-
 drivers/net/wireless/rt2x00/rt2800.h          |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c       |  107 +-
 drivers/net/wireless/rt2x00/rt2800pci.c       |   25 +-
 drivers/net/wireless/rt2x00/rt2800usb.c       |    5 +-
 drivers/net/wireless/rt2x00/rt2x00.h          |   28 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c       |   26 +-
 drivers/net/wireless/rt2x00/rt61pci.c         |   34 +-
 drivers/net/wireless/rt2x00/rt73usb.c         |   36 +-
 drivers/net/wireless/rtl818x/rtl8180.h        |    1 -
 drivers/net/wireless/rtl818x/rtl8180_dev.c    |   26 +-
 drivers/net/wireless/rtl818x/rtl8187.h        |    8 +-
 drivers/net/wireless/rtl818x/rtl8187_dev.c    |   27 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.c   |   72 +-
 drivers/net/wireless/rtl818x/rtl8187_leds.h   |    2 +
 drivers/net/wireless/rtl818x/rtl8187_rfkill.c |    4 +-
 drivers/net/wireless/wl12xx/wl1251_boot.c     |    2 +-
 drivers/net/wireless/wl12xx/wl1251_main.c     |   50 +-
 drivers/net/wireless/wl12xx/wl1271.h          |   35 +-
 drivers/net/wireless/wl12xx/wl1271_acx.c      |  134 ++--
 drivers/net/wireless/wl12xx/wl1271_acx.h      |   37 +-
 drivers/net/wireless/wl12xx/wl1271_boot.c     |    8 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.c      |   71 +-
 drivers/net/wireless/wl12xx/wl1271_cmd.h      |   33 +-
 drivers/net/wireless/wl12xx/wl1271_conf.h     |  100 ++-
 drivers/net/wireless/wl12xx/wl1271_debugfs.c  |   62 ++
 drivers/net/wireless/wl12xx/wl1271_event.c    |   20 +-
 drivers/net/wireless/wl12xx/wl1271_event.h    |    2 +-
 drivers/net/wireless/wl12xx/wl1271_init.c     |   12 +-
 drivers/net/wireless/wl12xx/wl1271_main.c     |  492 ++++++----
 drivers/net/wireless/wl12xx/wl1271_ps.c       |   15 +-
 drivers/net/wireless/wl12xx/wl1271_tx.c       |   43 +-
 drivers/net/wireless/zd1211rw/zd_chip.c       |  140 ---
 drivers/net/wireless/zd1211rw/zd_chip.h       |    3 -
 drivers/net/wireless/zd1211rw/zd_mac.c        |   13 +-
 include/linux/gigaset_dev.h                   |   22 +-
 include/linux/ieee80211.h                     |   41 +-
 include/linux/if_ether.h                      |    2 -
 include/linux/nl80211.h                       |   36 +
 include/net/cfg80211.h                        |   59 ++
 include/net/inet6_hashtables.h                |    2 +-
 include/net/inet_hashtables.h                 |    8 +-
 include/net/inet_timewait_sock.h              |    3 +
 include/net/mac80211.h                        |  111 ++--
 include/net/tcp.h                             |   22 -
 net/atm/br2684.c                              |   11 +-
 net/atm/lec.c                                 |   10 +-
 net/dccp/ipv4.c                               |    2 +-
 net/dccp/ipv6.c                               |    4 +-
 net/ipv4/inet_hashtables.c                    |   24 +-
 net/ipv4/inet_timewait_sock.c                 |   61 +-
 net/ipv4/tcp.c                                |    5 -
 net/ipv4/tcp_input.c                          |   35 +-
 net/ipv4/tcp_ipv4.c                           |    2 +-
 net/ipv4/tcp_timer.c                          |   29 +
 net/ipv6/inet6_hashtables.c                   |    8 +-
 net/ipv6/tcp_ipv6.c                           |    4 +-
 net/mac80211/Makefile                         |    4 +-
 net/mac80211/cfg.c                            |   35 +-
 net/mac80211/debugfs_netdev.c                 |    2 -
 net/mac80211/driver-ops.h                     |   77 ++-
 net/mac80211/driver-trace.h                   |   21 +
 net/mac80211/ht.c                             |   25 +-
 net/mac80211/ibss.c                           |   53 +-
 net/mac80211/ieee80211_i.h                    |  140 +++-
 net/mac80211/iface.c                          |   37 +-
 net/mac80211/key.c                            |    4 +-
 net/mac80211/main.c                           |   13 +-
 net/mac80211/mesh.c                           |    4 +-
 net/mac80211/mesh.h                           |    5 +-
 net/mac80211/mesh_hwmp.c                      |    2 +-
 net/mac80211/mlme.c                           | 1097 +++++------------=
-----
 net/mac80211/offchannel.c                     |  168 ++++
 net/mac80211/pm.c                             |    8 +-
 net/mac80211/rx.c                             |   12 +-
 net/mac80211/scan.c                           |  196 +---
 net/mac80211/sta_info.c                       |    7 +-
 net/mac80211/status.c                         |    2 +-
 net/mac80211/tx.c                             |    6 +-
 net/mac80211/util.c                           |  165 +++-
 net/mac80211/work.c                           | 1086 +++++++++++++++++=
++++
 net/rfkill/core.c                             |    4 +-
 net/wireless/Kconfig                          |   15 -
 net/wireless/chan.c                           |   41 +-
 net/wireless/core.h                           |    3 +
 net/wireless/mlme.c                           |   50 +-
 net/wireless/nl80211.c                        |  245 +++++-
 net/wireless/nl80211.h                        |   15 +
 net/wireless/reg.c                            |  114 +---
 net/wireless/scan.c                           |   13 +-
 net/wireless/wext-compat.c                    |    1 +
 166 files changed, 4946 insertions(+), 3730 deletions(-)
 create mode 100644 net/mac80211/offchannel.c
 create mode 100644 net/mac80211/work.c

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
009-12-28.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
