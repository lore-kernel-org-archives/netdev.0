From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 25 Sep 2009 00:29:13 -0700 (PDT)
Message-ID: <20090925.002913.241223287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36363
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751886AbZIYH2z convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 03:28:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Fix rt2x00 build failures, from Andrew Price.

2) 3c59x, fix double IRQ free.  From Anton Vorontsov.

3) Fix CONFIG_NET=3Dn build on some platforms.  From akpm

4) staging cpc-usb CAN driver upgraded to a bonafide driver
   under drivers/net/can/usb

5) Fix smsc95xx zero-length-pack scenerios and add some USB
   product IDs.

6) Fix packet generator scheduler unfriendliness, from Stephen
   Hemminger.

7) Handle bogus optlen for IP_MULTICAST_IF socket option.
   From Shan Wei.

8) phonet stack bug fixes from R=E9mi Denis-Courmont

9) Make sure SKY2_HW_RAM_BUFFER gets initialized properly in
   sky2 driver, from Mike McCormack.

10) If neither IFF_TUN nor IFF_TAP is set we must return -EINVAL
    in tap driver, from Kusanagi Kouichi.

11) 8139cp specifies KERN_* log level twice in printks.  Fix from
    Alan Jenkins.

12) b43 wireless bug fixes from Michael Buesch, Larry Finger, and
    Albert Herranz.

13) netxen bug fixes from Dhananjay Phadke.

14) More generic netlink locking fixes from Johannes Berg.

15) AX25 was busted by previous socket buffer allocation changes,
    fix from Eric Dumazet.

16) hostap netdev_ops conversion was buggy, fix from Martin Decky.

17) cpmac stopped building when BUS_ID_SIZE was removed, fix from
    Florian Fainelli.

18) kaweth memory leak fix from Kevin Cernekee.

19) New at91 CAN driver from Marc Kleine-Budde.

Please pull, thanks a lot!

The following changes since commit 94e0fb086fc5663c38bbc0fe86d698be8314=
f82f:
  Linus Torvalds (1):
        Merge branch 'drm-intel-next' of git://git.kernel.org/.../anhol=
t/drm-intel

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Alan Jenkins (1):
      8139cp: fix duplicate loglevel in module load message

Albert Herranz (2):
      b43: Add Soft-MAC SDIO device support
      b43: fix build error if !CONFIG_B43_LEDS

Alexander Duyck (1):
      igb: resolve namespacecheck warning for igb_hash_mc_addr

Andrew Morton (1):
      net: fix CONFIG_NET=3Dn build on sparc64

Andrew Price (1):
      rt2x00: fix the definition of rt2x00crypto_rx_insert_iv

Anton Vorontsov (1):
      3c59x: Get rid of "Trying to free already-free IRQ"

Christian Lamparter (2):
      p54usb: add Zcomax XG-705A usbid
      ar9170usb: add usbid for TP-Link TL-WN821N v2

Daniel C Halperin (1):
      iwlwifi: fix HT operation in 2.4 GHz band

David S. Miller (3):
      Merge branch 'master' of git://git.infradead.org/users/dwmw2/solo=
s-2.6
      Merge branch 'master' of git://git.kernel.org/.../linville/wirele=
ss-next-2.6
      Merge branch 'master' of /home/davem/src/GIT/linux-2.6/

David Woodhouse (1):
      solos: Add some margin-related parameters

Dhananjay Phadke (2):
      netxen: fix minor tx timeout bug
      netxen: fix firmware init after resume

Don Skidmore (1):
      ixgbe: fix sfp_timer clean up in ixgbe_down

Eric Dumazet (2):
      ax25: Fix SIOCAX25GETINFO ioctl
      tunnel: eliminate recursion field

=46abio Estevam (1):
      fec: Add FEC support for MX25 processor

=46lorian Fainelli (1):
      cpmac: fix compilation errors against undeclared BUS_ID_SIZE

Holger Schurig (2):
      cfg80211: use cfg80211_wext_freq() for freq conversion
      cfg80211: minimal error handling for wext-compat freq scanning

Jaswinder Singh Rajput (2):
      pcmcia: pcnet_cs.c removing useless condition
      net: fix htmldocs sunrpc, clnt.c

Joe Perches (1):
      lib/vsprintf.c: Avoid possible unaligned accesses in %pI6c

Johannes Berg (5):
      iwlwifi: disable powersave for 4965
      cfg80211: fix SME connect
      mac80211: fix DTIM setting
      cfg80211: don't overwrite privacy setting
      genetlink: fix netns vs. netlink table locking (2)

Julia Lawall (2):
      drivers/net: remove duplicate structure field initialization
      drivers/net/wireless: Use usb_endpoint_dir_out

Kevin Cernekee (1):
      kaweth: Fix memory leak in kaweth_control()

Kusanagi Kouichi (1):
      tun: Return -EINVAL if neither IFF_TUN nor IFF_TAP is set.

Larry Finger (2):
      ssb: Fix error when V1 SPROM extraction is forced
      b43: Implement RFKILL status for LP PHY

Luis R. Rodriguez (1):
      wireless: default CONFIG_WLAN to y

Marc Kleine-Budde (3):
      at91sam9263: add at91_can device to generic device definition
      at91sam9263ek: activate at91 CAN controller
      at91_can: add driver for Atmel's CAN controller on AT91SAM9263

Martin Decky (1):
      hostap: Revert a toxic part of the conversion to net_device_ops

Michael Buesch (11):
      b43: Force-wake queues on init
      ssb: Disable verbose SDIO coreswitch
      b43: Fix resume failure
      b43: Rewrite suspend/resume code
      b43: Do not use _irqsafe callbacks
      b43: Fix SDIO interrupt handler deadlock
      b43: Fix IRQ sync for SDIO
      b43: Add optional verbose runtime statistics
      b43: Disable PMQ mechanism
      b43: Don't abuse wl->current_dev in the led work
      b43: Remove BROKEN attribute from SDIO

Michael Chan (1):
      cnic: Shutdown iSCSI ring during uio_close.

Michal Simek (1):
      net: xilinx_emaclite: Fix problem with first incoming packet

Mike McCormack (1):
      sky2: Set SKY2_HW_RAM_BUFFER in sky2_init

Nathan Williams (2):
      solos: support new FPGA RAM layout
      solos: Check for rogue received packets

Nelson, Shannon (2):
      ixgbe: Allow tx itr specific settings
      ixgbe: move rx queue RSC configuration to a separate function

Pavel Roskin (1):
      rc80211_minstrel: fix contention window calculation

Randy Dunlap (2):
      ssb/sdio: fix printk format warnings
      wl12xx: fix kconfig/link errors

Reinette Chatre (3):
      iwlwifi: fix potential rx buffer loss
      iwlwifi: do not send sync command while holding spinlock
      iwlwifi: reduce noise when skb allocation fails

R=E9mi Denis-Courmont (2):
      Phonet: fix race for port number in concurrent bind()
      Phonet: error on broadcast sending (unimplemented)

Sebastian Haas (3):
      cpc-usb: Removed driver from staging tree
      ems_usb: Added support for EMS CPC-USB/ARM7 CAN/USB interface
      ems_pci: fix size of CAN controllers BAR mapping for CPC-PCI v2

Senthil Balasubramanian (2):
      ath9k: Adjust the chainmasks properly
      ath9k: Fix bug in chain handling

Shan Wei (1):
      ipv4: check optlen for IP_MULTICAST_IF option

Simon Farnsworth (1):
      solos: Show Interleaving details for ADSL2 and 2+

Stanislaw Gruszka (1):
      iwlagn: fix panic in iwl{5000,4965}_rx_reply_tx

Stephen Hemminger (2):
      pktgen: T_TERMINATE flag is unused
      pktgen: better scheduler friendliness

Steve Glendinning (2):
      smsc95xx: add additional USB product IDs
      smsc95xx: fix transmission where ZLP is expected

Sujith (5):
      ath9k: Fix bug in ANI channel handling
      ath9k: Restore TSF after RESET
      ath9k: Fix chip wakeup issue
      ath9k: Fix regression in PA calibration
      ath9k: Fix RFKILL bugs

Thomas Ilnseher (1):
      b43: Add LP PHY Analog Switch Support

Vasanthakumar Thiagarajan (3):
      ath9k: Fix rx data corruption
      ath9k: Don't read NF when chip has gone through full sleep mode
      ath9k: Do a full reset for AR9280

Vivek Natarajan (5):
      ath9k: Set default noise floor value for AR9287
      ath9k: Revamp PCIE workarounds
      ath9k: Fix AHB reset for AR9280
      ath9k: Disable autosleep feature by default.
      ath9k: Initialize txgain and rxgain for newer AR9287 chipsets.

Wey-Yi Guy (1):
      iwlwifi: find the correct first antenna

jie.yang@atheros.com (1):
      atl1c:remove compiling warning

roel kluin (1):
      atm: dereference of he_dev->rbps_virt in he_init_group()

 arch/arm/mach-at91/at91sam9263_devices.c    |   36 +
 arch/arm/mach-at91/board-sam9263ek.c        |   19 +
 arch/arm/mach-at91/include/mach/board.h     |    6 +
 drivers/atm/he.c                            |   59 ++-
 drivers/atm/solos-attrlist.c                |   11 +
 drivers/atm/solos-pci.c                     |   75 ++-
 drivers/net/3c59x.c                         |   12 +-
 drivers/net/8139cp.c                        |    2 +-
 drivers/net/Kconfig                         |    2 +-
 drivers/net/atl1c/atl1c_main.c              |    2 +-
 drivers/net/can/Kconfig                     |   13 +
 drivers/net/can/Makefile                    |    3 +
 drivers/net/can/sja1000/ems_pci.c           |   16 +-
 drivers/net/can/usb/Makefile                |    5 +
 drivers/net/can/usb/ems_usb.c               | 1155 +++++++++++++++++++=
+++++++
 drivers/net/cnic.c                          |    4 +-
 drivers/net/cpmac.c                         |    8 +-
 drivers/net/ehea/ehea_main.c                |    1 -
 drivers/net/igb/e1000_mac.c                 |   72 +-
 drivers/net/igb/e1000_mac.h                 |    1 -
 drivers/net/ixgbe/ixgbe.h                   |    6 +-
 drivers/net/ixgbe/ixgbe_ethtool.c           |   75 ++-
 drivers/net/ixgbe/ixgbe_main.c              |  111 ++-
 drivers/net/netxen/netxen_nic_main.c        |    8 +-
 drivers/net/pcmcia/pcnet_cs.c               |   11 +-
 drivers/net/sky2.c                          |    4 +-
 drivers/net/sunvnet.c                       |    1 -
 drivers/net/tun.c                           |    4 +-
 drivers/net/usb/kaweth.c                    |   18 +-
 drivers/net/usb/smsc95xx.c                  |   67 ++-
 drivers/net/usb/usbnet.c                    |    2 +-
 drivers/net/wireless/ath/ar9170/usb.c       |    2 +
 drivers/net/wireless/ath/ath9k/calib.c      |   23 +-
 drivers/net/wireless/ath/ath9k/calib.h      |    1 +
 drivers/net/wireless/ath/ath9k/eeprom_def.c |    4 +-
 drivers/net/wireless/ath/ath9k/hw.c         |  202 +++--
 drivers/net/wireless/ath/ath9k/hw.h         |    4 +-
 drivers/net/wireless/ath/ath9k/main.c       |   16 +-
 drivers/net/wireless/ath/ath9k/reg.h        |    3 +-
 drivers/net/wireless/b43/Kconfig            |   21 +-
 drivers/net/wireless/b43/Makefile           |    1 +
 drivers/net/wireless/b43/b43.h              |   23 +-
 drivers/net/wireless/b43/debugfs.c          |    1 +
 drivers/net/wireless/b43/debugfs.h          |    1 +
 drivers/net/wireless/b43/dma.c              |    4 +-
 drivers/net/wireless/b43/leds.c             |  266 +++++--
 drivers/net/wireless/b43/leds.h             |   33 +-
 drivers/net/wireless/b43/main.c             |  224 +++---
 drivers/net/wireless/b43/phy_lp.c           |   12 +-
 drivers/net/wireless/b43/pio.c              |    2 +-
 drivers/net/wireless/b43/rfkill.c           |    2 +-
 drivers/net/wireless/b43/sdio.c             |  202 +++++
 drivers/net/wireless/b43/sdio.h             |   45 +
 drivers/net/wireless/b43/xmit.c             |    5 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 +
 drivers/net/wireless/iwlwifi/iwl-5000.c     |    6 +
 drivers/net/wireless/iwlwifi/iwl-rx.c       |   10 +-
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    2 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    9 +-
 drivers/net/wireless/rt2x00/rt2x00lib.h     |    2 +-
 drivers/net/wireless/wl12xx/Kconfig         |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.c      |    2 +-
 drivers/net/xilinx_emaclite.c               |    7 +-
 drivers/staging/Kconfig                     |    2 -
 drivers/staging/Makefile                    |    1 -
 drivers/staging/cpc-usb/Kconfig             |    4 -
 drivers/staging/cpc-usb/Makefile            |    3 -
 drivers/staging/cpc-usb/TODO                |   10 -
 drivers/staging/cpc-usb/cpc-usb_drv.c       | 1184 -------------------=
--------
 drivers/staging/cpc-usb/cpc.h               |  417 ----------
 drivers/staging/cpc-usb/cpc_int.h           |   83 --
 drivers/staging/cpc-usb/cpcusb.h            |   86 --
 drivers/staging/cpc-usb/sja2m16c.h          |   41 -
 drivers/staging/cpc-usb/sja2m16c_2.c        |  452 ----------
 include/linux/netlink.h                     |    1 +
 include/linux/phonet.h                      |    1 +
 include/linux/usb/usbnet.h                  |    1 +
 include/net/ipip.h                          |    1 -
 kernel/sys_ni.c                             |    1 +
 lib/vsprintf.c                              |   25 +-
 net/ax25/af_ax25.c                          |    4 +-
 net/core/pktgen.c                           |  160 ++--
 net/ipv4/ip_gre.c                           |   13 +-
 net/ipv4/ip_sockglue.c                      |    3 +
 net/ipv4/ipip.c                             |    8 -
 net/ipv6/ip6_tunnel.c                       |    7 -
 net/ipv6/sit.c                              |    8 -
 net/mac80211/scan.c                         |    4 +-
 net/netlink/af_netlink.c                    |   19 +-
 net/netlink/genetlink.c                     |    4 +-
 net/phonet/af_phonet.c                      |    6 +
 net/phonet/socket.c                         |   16 +-
 net/sunrpc/clnt.c                           |    5 +-
 net/wireless/wext-sme.c                     |    2 +-
 94 files changed, 2613 insertions(+), 2911 deletions(-)
 create mode 100644 drivers/net/can/usb/Makefile
 create mode 100644 drivers/net/can/usb/ems_usb.c
 create mode 100644 drivers/net/wireless/b43/sdio.c
 create mode 100644 drivers/net/wireless/b43/sdio.h
 delete mode 100644 drivers/staging/cpc-usb/Kconfig
 delete mode 100644 drivers/staging/cpc-usb/Makefile
 delete mode 100644 drivers/staging/cpc-usb/TODO
 delete mode 100644 drivers/staging/cpc-usb/cpc-usb_drv.c
 delete mode 100644 drivers/staging/cpc-usb/cpc.h
 delete mode 100644 drivers/staging/cpc-usb/cpc_int.h
 delete mode 100644 drivers/staging/cpc-usb/cpcusb.h
 delete mode 100644 drivers/staging/cpc-usb/sja2m16c.h
 delete mode 100644 drivers/staging/cpc-usb/sja2m16c_2.c
