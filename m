From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-next-2.6 2011-03-11
Date: Fri, 11 Mar 2011 16:06:14 -0500
Message-ID: <20110311210614.GF14583@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

Welcome to this week's installment of updates from the wireless world
intended for 2.6.39... :-)  The biggest notables here are a bluetooth
pull from Gustavo, a wl12xx pull from Luca, and a number of rt2x00
updates, along with the usual smattering of various driver updates
and small enhancements and fixes here and there.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 1b7fe59322bef9e7a2c05b64a07a66b87529=
9736:

  ipv4: Kill flowi arg to fib_select_multipath() (2011-03-10 17:03:45 -=
0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-next-=
2.6.git for-davem

Anand Gadiyar (2):
      Bluetooth: fix build break on hci_sock.c
      Bluetooth: remove unnecessary call to hci_sock_cleanup

Anderson Briglia (1):
      Bluetooth: Fix LE conn creation

Arik Nemtsov (1):
      wl12xx: wakeup chip from ELP during scan

Ben Greear (2):
      ath9k: Fix txq memory address printing in debugfs.
      ath5k: Put hardware in PROMISC mode if there is more than 1 stati=
ons.

Bing Zhao (1):
      ieee80211: add IEEE80211_COUNTRY_STRING_LEN definition

Daniel Halperin (1):
      mac80211: update minstrel_ht sample rate when probe is set

=46ry, Donald H (1):
      iwlagn: report correct temperature for WiFi/BT devices.

Gabor Juhos (1):
      rt2x00: fix whitespace damage in the rt2800 specific code

Gertjan van Wingerde (4):
      rt2x00: Don't treat ATIM queue as second beacon queue.
      rt2x00: Include ATIM queue support in rt2x00queue_get_tx_queue.
      rt2x00: Optimize getting the beacon queue structure.
      rt2x00: Remove unused rt2x00queue_get_queue function.

Gustavo F. Padovan (1):
      Bluetooth: Remove duplicated BT_INFO() from L2CAP

Helmut Schaa (16):
      wl12xx: Correctly set up protection if non-GF STAs are present
      rt2x00: Optimize calls to rt2x00queue_get_queue
      rt2x00: Make use of unlikely during tx status processing
      rt2x00: Remove useless NULL check
      rt2x00: Add unlikely macro to special case tx status handling
      rt2x00: Use unlikely for unexpected error condition in rt2x00_mac=
_tx
      rt2x00: Generate sw sequence numbers only for devices that need i=
t
      rt2x00: Optimize TX descriptor handling
      rt2x00: Move TX descriptor field "ifs" into plcp substruct
      rt2x00: Don't call ieee80211_get_tx_rate for MCS rates
      rt2x00: Use an enum instead of u16 for the rate_mode TX descripto=
r field
      rt2x00: Fix rt2800 key assignment in multi bssid setups
      rt2x00: Remove now unused crypto.aid field
      rt2x00: Revise irqmask locking for PCI devices
      rt2x00: Fix comment in rt2800pci
      mac80211: Remove redundant preamble and RTS flag setup in minstre=
l_ht

Ido Yariv (9):
      wl12xx: Don't rely on runtime PM for toggling power
      wl12xx: Remove private headers in wl1271_tx_reset
      wl12xx: Reorder data handling in irq_work
      wl12xx: Do end-of-transactions transfers only if needed
      wl12xx: Change claiming of the SDIO bus
      wl12xx: Switch to a threaded interrupt handler
      wl12xx: Switch to level trigger interrupts
      wl12xx: Avoid redundant TX work
      wl12xx: Modify requested number of memory blocks

Ivo van Doorn (1):
      rt2x00: Optimize TX descriptor memory layout

Johan Hedberg (8):
      Bluetooth: Make pending_add return a pointer to the added entry
      Bluetooth: Add mgmt_pair_device command
      Bluetooth: Add management support for user confirmation request
      Bluetooth: Fix mgmt_pin_code_reply command status opcode
      Bluetooth: Fix mgmt_pin_code_reply return parameters
      Bluetooth: Add mgmt_auth_failed event
      Bluetooth: Fix inititial value for remote authentication requirem=
ents
      Bluetooth: Fix unnecessary list traversal in mgmt_pending_remove

Johannes Berg (1):
      mac80211: fix scan race, simplify code

John W. Linville (6):
      Merge branch 'master' of git://git.kernel.org/.../padovan/bluetoo=
th-next-2.6
      Merge branch 'for-linville' of git://git.kernel.org/.../luca/wl12=
xx
      Merge branch 'wireless-next-2.6' of git://git.kernel.org/.../iwlw=
ifi/iwlwifi-2.6
      rtlwifi: usb parts should depend on CONFIG_USB
      ath5k: restrict AR5K_TX_QUEUE_ID_DATA_MAX to reflect the [0,3] ra=
nge
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6 into for-davem

Larry Finger (1):
      rtl8187: Change rate-control feedback

Michael Buesch (3):
      lib-average: Make config option selectable
      mac80211: Add log message to ieee80211_restart_hw()
      p54spi: Update kconfig help text

Rafa=C5=82 Mi=C5=82ecki (4):
      b43: N-PHY: rev3+: correct switching analog core
      b43: N-PHY: rev3+: add tables with gain ctl workarounds
      b43: N-PHY: rev3+: implement gain ctl workarounds
      b43: trivial: update B43_PHY_N description (PHY support)

Scott James Remnant (1):
      net/wireless: add COUNTRY to to regulatory device uevent

Sebastien Jan (1):
      wl12xx: fix the path to the wl12xx firmwares

Shan Wei (3):
      mac80211: remove unused macros
      wireless:ath: use resource_size() help function
      mwl8k: use kcalloc instead of kmalloc & memset

Stanislaw Gruszka (4):
      iwlwifi: move rx handlers code to iwl-rx.c
      iwlwifi: cleanup iwl_good_plcp_health
      iwlwifi: avoid too frequent recover from statistics
      iwlwifi: fix iwl-rx.c compilation

Szymon Janc (8):
      Bluetooth: Use proper command structure in remove_uuid
      Bluetooth: Move index to common header in management interface
      Bluetooth: Validate data size before accessing mgmt commands
      Bluetooth: Fix possible NULL pointer dereference in cmd_complete
      Bluetooth: Log all parameters in cmd_status for easier debugging
      Bluetooth: Remove unused code from get_connections
      Bluetooth: Use variable name instead of type in sizeof()
      Bluetooth: Fix some small code style issues in mgmt.c

Vasanthakumar Thiagarajan (2):
      ath9k: Add a debugfs interface to dump chip registers
      ath9k_hw: Read noise floor only for available chains for AR9003

Ville Tervo (1):
      Bluetooth: Use ERR_PTR as return error from hci_connect

 drivers/net/wireless/at76c50x-usb.h            |    2 +-
 drivers/net/wireless/ath/ath5k/ahb.c           |    2 +-
 drivers/net/wireless/ath/ath5k/ath5k.h         |    2 +-
 drivers/net/wireless/ath/ath5k/base.c          |   52 +-
 drivers/net/wireless/ath/ath5k/base.h          |   13 +
 drivers/net/wireless/ath/ath5k/mac80211-ops.c  |   19 +-
 drivers/net/wireless/ath/ath9k/ahb.c           |    2 +-
 drivers/net/wireless/ath/ath9k/ar9003_phy.c    |   37 +-
 drivers/net/wireless/ath/ath9k/debug.c         |   62 ++-
 drivers/net/wireless/b43/Kconfig               |    2 +-
 drivers/net/wireless/b43/phy_n.c               |  179 ++++++-
 drivers/net/wireless/b43/tables_nphy.c         |  103 ++++
 drivers/net/wireless/b43/tables_nphy.h         |   25 +
 drivers/net/wireless/ipw2x00/ipw2200.h         |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-lib.c     |  242 +--------
 drivers/net/wireless/iwlwifi/iwl-agn.c         |  178 +------
 drivers/net/wireless/iwlwifi/iwl-agn.h         |   13 +-
 drivers/net/wireless/iwlwifi/iwl-core.c        |   63 --
 drivers/net/wireless/iwlwifi/iwl-core.h        |   18 +-
 drivers/net/wireless/iwlwifi/iwl-dev.h         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-rx.c          |  665 ++++++++++++++++=
++----
 drivers/net/wireless/libertas/host.h           |    2 +-
 drivers/net/wireless/mwl8k.c                   |    6 +-
 drivers/net/wireless/p54/Kconfig               |    5 +-
 drivers/net/wireless/rt2x00/rt2400pci.c        |   36 +-
 drivers/net/wireless/rt2x00/rt2500pci.c        |   38 +-
 drivers/net/wireless/rt2x00/rt2500usb.c        |   13 +-
 drivers/net/wireless/rt2x00/rt2800.h           |   40 +-
 drivers/net/wireless/rt2x00/rt2800lib.c        |  753 ++++++++++++----=
--------
 drivers/net/wireless/rt2x00/rt2800pci.c        |   33 +-
 drivers/net/wireless/rt2x00/rt2800usb.c        |    1 +
 drivers/net/wireless/rt2x00/rt2x00.h           |   26 +-
 drivers/net/wireless/rt2x00/rt2x00ht.c         |   28 +-
 drivers/net/wireless/rt2x00/rt2x00mac.c        |   20 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c      |  109 ++--
 drivers/net/wireless/rt2x00/rt2x00queue.h      |   29 +-
 drivers/net/wireless/rt2x00/rt61pci.c          |   31 +-
 drivers/net/wireless/rt2x00/rt73usb.c          |   14 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c     |   25 +-
 drivers/net/wireless/rtl818x/rtl8187/rtl8187.h |    2 +
 drivers/net/wireless/rtlwifi/Makefile          |    9 +-
 drivers/net/wireless/wl1251/wl12xx_80211.h     |    3 +-
 drivers/net/wireless/wl12xx/acx.c              |    3 +-
 drivers/net/wireless/wl12xx/boot.c             |    3 +
 drivers/net/wireless/wl12xx/boot.h             |    5 +
 drivers/net/wireless/wl12xx/cmd.c              |    1 +
 drivers/net/wireless/wl12xx/debugfs.c          |    2 +-
 drivers/net/wireless/wl12xx/io.h               |    1 +
 drivers/net/wireless/wl12xx/main.c             |  170 ++++--
 drivers/net/wireless/wl12xx/ps.c               |    6 +-
 drivers/net/wireless/wl12xx/ps.h               |    2 +-
 drivers/net/wireless/wl12xx/rx.c               |   11 +-
 drivers/net/wireless/wl12xx/scan.c             |   20 +-
 drivers/net/wireless/wl12xx/sdio.c             |   42 +-
 drivers/net/wireless/wl12xx/spi.c              |   19 +-
 drivers/net/wireless/wl12xx/tx.c               |   47 ++-
 drivers/net/wireless/wl12xx/wl12xx.h           |   28 +-
 drivers/net/wireless/wl12xx/wl12xx_80211.h     |    3 +-
 include/linux/ieee80211.h                      |    3 +
 include/net/bluetooth/hci.h                    |   17 +
 include/net/bluetooth/hci_core.h               |   21 +
 include/net/bluetooth/mgmt.h                   |   73 ++-
 lib/Kconfig                                    |    9 +-
 net/bluetooth/af_bluetooth.c                   |    4 +-
 net/bluetooth/hci_conn.c                       |    8 +-
 net/bluetooth/hci_event.c                      |   69 ++-
 net/bluetooth/hci_sock.c                       |    2 +-
 net/bluetooth/l2cap_core.c                     |   13 +-
 net/bluetooth/mgmt.c                           |  751 ++++++++++++++++=
--------
 net/bluetooth/sco.c                            |    7 +-
 net/mac80211/key.h                             |    1 -
 net/mac80211/main.c                            |    3 +
 net/mac80211/rc80211_minstrel_ht.c             |   19 +-
 net/mac80211/rc80211_pid.h                     |    3 -
 net/mac80211/scan.c                            |   64 +--
 net/mac80211/work.c                            |    1 -
 net/wireless/reg.c                             |   39 +-
 net/wireless/reg.h                             |    1 +
 78 files changed, 2610 insertions(+), 1769 deletions(-)

Omnibus patch is available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-next-2=
=2E6-2011-03-11.patch.bz2

--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
