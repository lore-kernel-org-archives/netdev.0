From: Jeff Garzik <jeff@garzik.org>
Subject: What's in netdev-2.6.git?
Date: Sat, 8 Sep 2007 13:24:12 -0400
Message-ID: <20070908172412.GA9661@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57605 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752891AbXIHRYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Sep 2007 13:24:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


The following is the current contents of
git://git.kernel.org/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git
(recently rebased)

The 'upstream' branch is what I will push upstream for 2.6.24, once
the merge window opens.  I also have a pile in my inbox I need to go
over, while I was away at conference.

List of branches
----------------
  ALL		=3D=3D contents of branches: upstream, stats, ethtool
  ethtool
* master
  stats
  upstream

branch upstream
---------------
Andrew Morton (1):
      libertas: printk warning fixes

Auke Kok (13):
      e1000e: New pci-express e1000 driver (currently for ICH9 devices =
only)
      e1000e: Remove unused or empty labels
      e1000e: Make a few functions static
      e1000e: remove duplicate shadowing reference to adapter->hw
      e1000e: Fix header includes [v2]
      e1000e: remove namespace collisions with e1000
      e1000e: Use dma_alloc_coherent where possible
      e1000e: Use time_after to account for jiffies wrapping
      e1000e: error handling for pci_map_single calls.
      e1000e: Remove two compile warnings
      e1000e: retire last_tx_tso workaround
      e1000e: Add read code and printout of PBA number (board identifie=
r)
      e1000e: Remove conditional packet split disable flag

Bill Nottingham (1):
      remove gratuitous space in airo module description

Brajesh Dave (1):
      libertas: advertise 11g ad-hoc rates

Brian King (6):
      ibmveth: Enable TCP checksum offload
      ibmveth: Implement ethtool hooks to enable/disable checksum offlo=
ad
      ibmveth: Add ethtool TSO handlers
      ibmveth: Add ethtool driver stats hooks
      ibmveth: Remove dead frag processing code
      ibmveth: Remove use of bitfields

Dan Williams (31):
      libertas: kill ieeetypes_capinfo bitfield, use ieee80211.h types
      libertas: rename WLAN_802_11_KEY to enc_key and clean up usage
      libertas: clean up indentation in libertas_association_worker
      libertas: clean up 802.11 IE post-scan handling
      libertas: remove if_bootcmd.c
      libertas: fix mixed-case abuse in cmd_ds_802_11_scan
      libertas: fix mixed-case abuse in cmd_ds_802_11_ad_hoc_result
      libertas: fix mixed-case abuse in cmd_ds_802_11_ad_hoc_start
      libertas: re-uppercase command defines and other constants
      libertas: fix debug build breakage due to field rename
      libertas: remove thread.h and make kthread usage clearer
      libertas: new mesh control knobs
      libertas: bump version to 322.p1
      libertas: fix more mixed-case abuse
      libertas: move generic firmware reset command to common code
      libertas: wlan_ -> libertas_ function prefix renames for main.c
      libertas: simplify and clean up data rate handling
      libertas: fix WEXT quality reporting
      libertas: send association events on adhoc reassociation
      libertas: push mesh beacon bit to userspace in scan results
      libertas: fix assignment of WEP key type
      libertas: push WEXT scan requests to a work queue
      libertas: fix misspelling in debug message
      libertas: ignore spurious mesh autostart events
      libertas: better descriptions for association errors
      libertas: fix sparse-reported problems
      libertas: bump driver version
      libertas: fix inadvertant removal of bits from commit 83144186295=
6fffa17b9801db37e6ea1650b0f69
      libertas: reorganize and simplify init sequence
      libertas: don't stomp on interface-specific private data
      libertas: send reset command directly instead of calling libertas=
_reset_device

Daniel Drake (2):
      zd1211rw: Add ID for Sitecom WL-162
      zd1211rw: Add ID for ZyXEL M-202 XtremeMIMO

Denis Cheng (1):
      drivers/net/cxgb3: removed several unneeded zero initilization

Divy Le Ray (9):
      cxgb3 - MAC workaround update
      cxgb3 - Update rx coalescing length
      cxgb3 - SGE doorbell overflow warning
      cxgb3 - use immediate data for offload Tx
      cxgb3 - Expose HW memory page info
      cxgb3 - tighten checks on TID values
      cxgb3 - Fatal error update
      cxgb3 - log adapter serial number
      cxgb3 - Update internal memory management

Don Fry (1):
      pcnet32: add suspend and resume capability

Eugene Teo (1):
      drivers/net/wireless/libertas/cmd.c: fix adapter->driver_lock der=
eference

=46aidon Liambotis (2):
      Kconfig: order options
      Kconfig: remove references of pcmcia-cs

Holger Schurig (33):
      libertas: remove fw.c
      libertas: fix one more sparse warning
      libertas: make more functions static & remove unused functions
      libertas: uppercase some #defines
      libertas: access mesh_dev more carefully
      libertas: tune hardware info output
      libertas: remove debugmode
      libertas: make the hex dumper nicer
      libertas: remove a hundred CMD_RET_xxx definitions
      libertas: use LBS_DEB_HOST for host-to-card communications
      libertas: use LBS_DEB_HOST for host-to-card communications
      add support for Marvell 8385 CF cards
      libertas: remove unused adapter->prev_XXXX variables
      libertas: remove adapter->{rx,tx}antenna
      libertas: remove adapter->prescan
      libertas: remove adapter->scanprobes
      libertas: remove adapter->pkttxctrl
      libertas: remove adapter->txrate
      libertas: remove adapter->rxpd_rate
      libertas: remove adapter->{data,bcn}_avg_factor
      libertas: remove adapter->nullpktinterval
      libertas: remove adapter->locallisteninterval
      libertas: remove adapter->multipledtim
      libertas: remove adapter->atimwindow
      libertas: remove adapter->regiontableindex
      libertas: remove adapter->listeninterval
      libertas: remove adapter->adhoc_grate_enabled
      libertas: remove adapter->beaconperiod
      libertas: remove adapter->scanmode
      libertas: remove adapter->scantype
      libertas: remove bss_descriptior->networktsf
      libertas: remove bss_descriptor->timestamp
      libertas: fix two debug statements in cmdresp.c

Jean Tourrilhes (1):
      libertas: fix a few wext abuses...

Jeff Garzik (6):
      [netdrvr] skfp: remove a bunch of dead code
      drivers/net/skfp: Remove dead code referencing pci_find_device()
      [netdrvr] 8139cp, 8139too: convert to generic DMA
      [netdrvr] 8139too: tab-align enums and structs; remove dead code
      [netdrvr] 8139too: clean up I/O remapping
      [netdrvr] ns83820: add ethtool media support

Jeremy Fitzhardinge (1):
      xen-netfront: remove dead code

Jesper Juhl (2):
      Clean up duplicate includes in drivers/net/
      net: Kill some unneeded allocation return value casts in libertas

Johannes Berg (1):
      rtl8187: remove IEEE80211_HW_DATA_NULLFUNC_ACK

John W. Linville (1):
      libertas: remove unused adhoc_rates_b definition

Komuro (1):
      dl2k: add Sundance/Tamarack TC902x Gigabit Ethernet Adapter suppo=
rt

Luis Carlos Cobo (7):
      libertas: specific mesh scan for mshX interface
      Support for mesh autostart deactivation through sysfs
      libertas: Avoid MESH_AUTOSTARTED spam on console
      libertas: revert CAPINFO_MASK to its original value
      libertas: keep mesh autostart enabled while asleep
      libertas: monitor mode support for OLPC firmware
      libertas: pass boot2 version to firmware

Marek Va=C5=A1ut (1):
      libertas: region code values specified as 8bit

Mariusz Kozlowski (6):
      drivers/net/wireless/prism54/oid_mgt.c: kmalloc + memset conversi=
on to kzalloc
      drivers/net/sb1250-mac.c: kmalloc + memset conversion to kcalloc
      drivers/net/via-velocity.c: mostly kmalloc + memset conversion to=
 kcalloc
      net/tulip/xircom_cb.c: remove superfulous priv assignment
      drivers/net: remove superfluous memset
      drivers/net/wireless/wl3501_cs.c: remove redundant memset

Mark Hindley (1):
      3c59x: check return of pci_enable_device()

Masakazu Mokuno (2):
      PS3: changed the way to handle tx skbs
      PS3: Remove the workaround no longer needed

Matthias Kaehlcke (1):
      Use mutex instead of semaphore in the Host AP driver

Olaf Hering (1):
      bmac: add simple ethtool support for network manager

Oliver Neukum (1):
      support for USB autosuspend in the asix driver

Olof Johansson (10):
      pasemi_mac: Abstract out register access
      pasemi_mac: Stop using the pci config space accessors for registe=
r read/writes
      pasemi_mac: Enable L2 caching of packet headers
      pasemi_mac: Fix memcpy amount for short receives
      pasemi_mac: RX performance tweaks
      pasemi_mac: Batch up TX buffer frees
      pasemi_mac: Enable LLTX
      pasemi_mac: Fix TX ring wrap checking
      pasemi_mac: Fix RX checksum flags
      pasemi_mac: Clean TX ring in poll

Pierre Ossman (1):
      libertas: properly end commands on hardware failure

Rafael J. Wysocki (1):
      uli526x: Add suspend and resume routines (updated)

Ralf Baechle (1):
      IOC3: Switch hw checksumming to ethtool configurable.

Richard Knutsson (2):
      drivers/net/tokenring: Convert to generic boolean
      drivers/net/3c505: Convert to generic boolean

Sivakumar Subramani (3):
      S2IO: Making MSIX as default intr_type
      S2IO: Fixes in MSIX related code.
      S2IO: Fixed Link LED issue when MSI-X is enabled

Stephen Hemminger (6):
      sky2: fe+ chip support
      sky2: use debugfs rename
      sky2: document GPHY_CTRL bits
      sky2: dont restrict config space access
      sky2: advanced error reporting
      sky2: use pci_config access functions

Surya Prabhakar N (1):
      drivers/net/tokenring/3c359.c

Ulrich Kunitz (3):
      zd1211rw: monitor all packets
      zd1211rw: removed noisy debug messages
      zd1211rw: consistent handling of ZD1211 specific rates

Yoann Padioleau (2):
      dev->priv to netdev_priv(dev), for drivers/net/wireless
      dev->priv to netdev_priv(dev), drivers/net/tokenring/

 drivers/net/3c505.c                          |   67=20
 drivers/net/3c59x.c                          |   36=20
 drivers/net/8139cp.c                         |   31=20
 drivers/net/8139too.c                        |  410 +-
 drivers/net/Kconfig                          |   50=20
 drivers/net/Makefile                         |    1=20
 drivers/net/atl1/atl1_main.c                 |    1=20
 drivers/net/bfin_mac.c                       |    5=20
 drivers/net/bmac.c                           |   13=20
 drivers/net/bonding/bond_sysfs.c             |    1=20
 drivers/net/cxgb3/common.h                   |    5=20
 drivers/net/cxgb3/cxgb3_ctl_defs.h           |   52=20
 drivers/net/cxgb3/cxgb3_defs.h               |   20=20
 drivers/net/cxgb3/cxgb3_main.c               |   16=20
 drivers/net/cxgb3/cxgb3_offload.c            |   35=20
 drivers/net/cxgb3/regs.h                     |   10=20
 drivers/net/cxgb3/sge.c                      |   21=20
 drivers/net/cxgb3/t3_hw.c                    |    5=20
 drivers/net/cxgb3/xgmac.c                    |   22=20
 drivers/net/dl2k.c                           |   23=20
 drivers/net/dl2k.h                           |    1=20
 drivers/net/e1000e/82571.c                   | 1351 ++++++++
 drivers/net/e1000e/Makefile                  |   37=20
 drivers/net/e1000e/defines.h                 |  739 ++++
 drivers/net/e1000e/e1000.h                   |  512 +++
 drivers/net/e1000e/es2lan.c                  | 1232 +++++++
 drivers/net/e1000e/ethtool.c                 | 1774 ++++++++++
 drivers/net/e1000e/hw.h                      |  864 +++++
 drivers/net/e1000e/ich8lan.c                 | 2225 +++++++++++++
 drivers/net/e1000e/lib.c                     | 2487 +++++++++++++++
 drivers/net/e1000e/netdev.c                  | 4449 ++++++++++++++++++=
+++++++++
 drivers/net/e1000e/param.c                   |  382 ++
 drivers/net/e1000e/phy.c                     | 1773 ++++++++++
 drivers/net/fs_enet/fs_enet-main.c           |    3=20
 drivers/net/gianfar.h                        |    1=20
 drivers/net/gianfar_ethtool.c                |    1=20
 drivers/net/ibmveth.c                        |  319 +
 drivers/net/ibmveth.h                        |   55=20
 drivers/net/ioc3-eth.c                       |   48=20
 drivers/net/irda/kingsun-sir.c               |    1=20
 drivers/net/irda/mcs7780.c                   |    1=20
 drivers/net/mipsnet.c                        |    1=20
 drivers/net/myri10ge/myri10ge.c              |    1=20
 drivers/net/netxen/netxen_nic_main.c         |    2=20
 drivers/net/ns83820.c                        |  151=20
 drivers/net/pasemi_mac.c                     |  389 +-
 drivers/net/pasemi_mac.h                     |   13=20
 drivers/net/pcnet32.c                        |   35=20
 drivers/net/ps3_gelic_net.c                  |  156=20
 drivers/net/qla3xxx.c                        |    1=20
 drivers/net/s2io-regs.h                      |    2=20
 drivers/net/s2io.c                           |  129=20
 drivers/net/s2io.h                           |    7=20
 drivers/net/sb1250-mac.c                     |    6=20
 drivers/net/skfp/drvfbi.c                    |  733 ----
 drivers/net/skfp/h/mbuf.h                    |    4=20
 drivers/net/skfp/h/skfbi.h                   |  788 ----
 drivers/net/skfp/h/skfbiinc.h                |   26=20
 drivers/net/skfp/h/targethw.h                |   33=20
 drivers/net/skfp/hwt.c                       |   42=20
 drivers/net/sky2.c                           |  274 -
 drivers/net/sky2.h                           |  104=20
 drivers/net/sunlance.c                       |    1=20
 drivers/net/tokenring/3c359.c                |   64=20
 drivers/net/tokenring/ibmtr.c                |   43=20
 drivers/net/tokenring/lanstreamer.c          |   32=20
 drivers/net/tokenring/madgemc.c              |    4=20
 drivers/net/tokenring/olympic.c              |   36=20
 drivers/net/tokenring/tmspci.c               |    4=20
 drivers/net/tsi108_eth.c                     |    1=20
 drivers/net/tulip/uli526x.c                  |  108=20
 drivers/net/tulip/xircom_cb.c                |    1=20
 drivers/net/usb/asix.c                       |    1=20
 drivers/net/usb/pegasus.c                    |    1=20
 drivers/net/usb/rtl8150.c                    |    1=20
 drivers/net/usb/usbnet.c                     |   30=20
 drivers/net/usb/usbnet.h                     |    1=20
 drivers/net/via-velocity.c                   |   24=20
 drivers/net/wireless/Kconfig                 |   92=20
 drivers/net/wireless/Makefile                |    2=20
 drivers/net/wireless/airo.c                  |    4=20
 drivers/net/wireless/arlan-proc.c            |   14=20
 drivers/net/wireless/hostap/hostap_cs.c      |    2=20
 drivers/net/wireless/hostap/hostap_hw.c      |   16=20
 drivers/net/wireless/hostap/hostap_ioctl.c   |   14=20
 drivers/net/wireless/hostap/hostap_wlan.h    |    3=20
 drivers/net/wireless/ipw2200.h               |    1=20
 drivers/net/wireless/libertas/11d.c          |  124=20
 drivers/net/wireless/libertas/11d.h          |    4=20
 drivers/net/wireless/libertas/Makefile       |    5=20
 drivers/net/wireless/libertas/assoc.c        |   99=20
 drivers/net/wireless/libertas/assoc.h        |    2=20
 drivers/net/wireless/libertas/cmd.c          |  666 ++--
 drivers/net/wireless/libertas/cmdresp.c      |  374 +-
 drivers/net/wireless/libertas/debugfs.c      |  139=20
 drivers/net/wireless/libertas/decl.h         |   19=20
 drivers/net/wireless/libertas/defs.h         |  157=20
 drivers/net/wireless/libertas/dev.h          |   81=20
 drivers/net/wireless/libertas/ethtool.c      |   11=20
 drivers/net/wireless/libertas/fw.c           |  349 --
 drivers/net/wireless/libertas/host.h         |  445 +-
 drivers/net/wireless/libertas/hostcmd.h      |   81=20
 drivers/net/wireless/libertas/if_bootcmd.c   |   40=20
 drivers/net/wireless/libertas/if_cs.c        |  961 +++++
 drivers/net/wireless/libertas/if_usb.c       |  370 +-
 drivers/net/wireless/libertas/if_usb.h       |    8=20
 drivers/net/wireless/libertas/join.c         |  471 +-
 drivers/net/wireless/libertas/join.h         |   35=20
 drivers/net/wireless/libertas/main.c         |  874 +++--
 drivers/net/wireless/libertas/rx.c           |   85=20
 drivers/net/wireless/libertas/scan.c         |  585 +--
 drivers/net/wireless/libertas/scan.h         |   36=20
 drivers/net/wireless/libertas/thread.h       |   52=20
 drivers/net/wireless/libertas/tx.c           |   41=20
 drivers/net/wireless/libertas/types.h        |   67=20
 drivers/net/wireless/libertas/wext.c         |  391 --
 drivers/net/wireless/libertas/wext.h         |    9=20
 drivers/net/wireless/orinoco_tmd.c           |    2=20
 drivers/net/wireless/prism54/isl_ioctl.c     |    6=20
 drivers/net/wireless/prism54/oid_mgt.c       |    4=20
 drivers/net/wireless/ray_cs.c                |   66=20
 drivers/net/wireless/rtl8187_dev.c           |    3=20
 drivers/net/wireless/strip.c                 |    2=20
 drivers/net/wireless/wl3501_cs.c             |   67=20
 drivers/net/wireless/zd1211rw/zd_chip.c      |   69=20
 drivers/net/wireless/zd1211rw/zd_chip.h      |    5=20
 drivers/net/wireless/zd1211rw/zd_def.h       |    1=20
 drivers/net/wireless/zd1211rw/zd_ieee80211.h |   43=20
 drivers/net/wireless/zd1211rw/zd_mac.c       |  143=20
 drivers/net/wireless/zd1211rw/zd_mac.h       |   65=20
 drivers/net/wireless/zd1211rw/zd_usb.c       |    2=20
 drivers/net/xen-netfront.c                   |   37=20
 132 files changed, 23510 insertions(+), 6062 deletions(-)


branch stats
------------
Jeff Garzik (1):
      drivers/net: statistics cleanup #1 -- save memory and shrink code

 drivers/net/3c501.c        |   41 ++++-------------
 drivers/net/3c501.h        |    2=20
 drivers/net/3c507.c        |   52 ++++++++--------------
 drivers/net/7990.c         |   47 ++++++++------------
 drivers/net/7990.h         |    2=20
 drivers/net/82596.c        |   65 +++++++++++-----------------
 drivers/net/a2065.c        |   51 +++++++++-------------
 drivers/net/at1700.c       |   39 +++++-----------
 drivers/net/atarilance.c   |   58 ++++++++-----------------
 drivers/net/atp.c          |   49 +++++++--------------
 drivers/net/au1000_eth.c   |   23 +--------
 drivers/net/au1000_eth.h   |    1=20
 drivers/net/bfin_mac.c     |   25 ++--------
 drivers/net/bfin_mac.h     |    2=20
 drivers/net/bmac.c         |   48 ++++++++------------
 drivers/net/de600.c        |   15 +-----
 drivers/net/de600.h        |    1=20
 drivers/net/de620.c        |   26 +++--------
 drivers/net/declance.c     |   52 +++++++++-------------
 drivers/net/depca.c        |   42 ++++++------------
 drivers/net/dgrs.c         |   24 +---------
 drivers/net/dm9000.c       |   29 +++---------
 drivers/net/e100.c         |   23 +++------
 drivers/net/eepro.c        |   47 +++++++-------------
 drivers/net/eexpress.c     |   56 +++++++++---------------
 drivers/net/eql.c          |   12 -----
 drivers/net/eth16i.c       |   49 ++++++++-------------
 drivers/net/ewrk3.c        |   37 +++++-----------
 drivers/net/fec.c          |   50 ++++++++-------------
 drivers/net/gianfar.c      |   40 ++++++-----------
 drivers/net/hplance.c      |    1=20
 drivers/net/ibmlana.c      |   37 ++++++----------
 drivers/net/ibmlana.h      |    1=20
 drivers/net/ibmveth.c      |   18 ++-----
 drivers/net/ifb.c          |   20 --------
 drivers/net/iseries_veth.c |   22 ++-------
 drivers/net/lib82596.c     |   64 +++++++++++----------------
 drivers/net/lp486e.c       |   56 +++++++++---------------
 drivers/net/mace.c         |   51 ++++++++--------------
 drivers/net/macmace.c      |   49 ++++++++-------------
 drivers/net/meth.c         |   28 ++++--------
 drivers/net/mipsnet.c      |   26 ++---------
 drivers/net/mv643xx_eth.c  |   25 +---------
 drivers/net/myri_sbus.c    |   20 +++-----
 drivers/net/myri_sbus.h    |    1=20
 drivers/net/netx-eth.c     |   18 ++-----
 drivers/net/ni5010.c       |   47 +++++---------------
 drivers/net/pasemi_mac.c   |   17 +------
 drivers/net/pasemi_mac.h   |    1=20
 drivers/net/pci-skeleton.c |   74 +++++++++-----------------------
 drivers/net/plip.c         |   32 ++++---------
 drivers/net/qla3xxx.c      |   23 +++------
 drivers/net/qla3xxx.h      |    1=20
 drivers/net/rionet.c       |   20 ++------
 drivers/net/rrunner.c      |   31 ++++---------
 drivers/net/rrunner.h      |    2=20
 drivers/net/saa9730.c      |   93 ++++++++++++++++++------------------=
----
 drivers/net/saa9730.h      |    1=20
 drivers/net/sb1000.c       |   19 ++------
 drivers/net/sb1250-mac.c   |   37 +++-------------
 drivers/net/seeq8005.c     |   33 ++++----------
 drivers/net/sgiseeq.c      |   34 +++++---------
 drivers/net/shaper.c       |   15 +-----
 drivers/net/sis190.c       |   19 ++------
 drivers/net/sis900.c       |   56 ++++++++----------------
 drivers/net/smc911x.c      |   77 ++++++++++++---------------------
 drivers/net/smc9194.c      |   59 +++++++------------------
 drivers/net/smc91x.c       |   69 ++++++++++-------------------
 drivers/net/spider_net.c   |   31 +++----------
 drivers/net/spider_net.h   |    1=20
 drivers/net/sun3lance.c    |   53 ++++++++--------------
 drivers/net/sunlance.c     |   87 ++++++++++++++++--------------------=
-
 drivers/net/sunqe.c        |  104 ++++++++++++++++++++----------------=
---------
 drivers/net/sunqe.h        |    1=20
 drivers/net/tun.c          |   23 +++------
 drivers/net/ucc_geth.c     |   27 +++--------
 drivers/net/ucc_geth.h     |    1=20
 drivers/net/xen-netfront.c |   26 +++--------
 drivers/net/yellowfin.c    |   63 +++++++++++----------------
 drivers/net/znet.c         |   50 ++++++++-------------
 include/linux/if_eql.h     |    1=20
 include/linux/if_shaper.h  |    1=20
 include/linux/if_tun.h     |    1=20
 83 files changed, 930 insertions(+), 1745 deletions(-)


branch ethtool
--------------
Jeff Garzik (1):
      [ETHTOOL] Provide default behaviors for a few ethtool sub-ioctls

 drivers/net/8139cp.c                    |    3 ---
 drivers/net/atl1/atl1_ethtool.c         |    3 ---
 drivers/net/bnx2.c                      |    3 ---
 drivers/net/bonding/bond_main.c         |    4 ----
 drivers/net/chelsio/cxgb2.c             |    3 ---
 drivers/net/cxgb3/cxgb3_main.c          |    3 ---
 drivers/net/e1000/e1000_ethtool.c       |    2 --
 drivers/net/ehea/ehea_ethtool.c         |    3 ---
 drivers/net/epic100.c                   |    2 --
 drivers/net/fealnx.c                    |    2 --
 drivers/net/fec_8xx/fec_main.c          |    2 --
 drivers/net/forcedeth.c                 |    3 ---
 drivers/net/fs_enet/fs_enet-main.c      |    2 --
 drivers/net/ibm_emac/ibm_emac_core.c    |    2 --
 drivers/net/ibmveth.c                   |    6 +-----
 drivers/net/ixgb/ixgb_ethtool.c         |    2 --
 drivers/net/loopback.c                  |    1 -
 drivers/net/macvlan.c                   |    4 ----
 drivers/net/mv643xx_eth.c               |    1 -
 drivers/net/myri10ge/myri10ge.c         |    3 ---
 drivers/net/ne2k-pci.c                  |    2 --
 drivers/net/netxen/netxen_nic_ethtool.c |    3 ---
 drivers/net/pcnet32.c                   |    3 ---
 drivers/net/r8169.c                     |    3 ---
 drivers/net/s2io.c                      |    3 ---
 drivers/net/sc92031.c                   |    4 ----
 drivers/net/skge.c                      |    2 --
 drivers/net/sky2.c                      |    3 ---
 drivers/net/spider_net_ethtool.c        |    1 -
 drivers/net/tg3.c                       |    3 ---
 drivers/net/tulip/de2104x.c             |    2 --
 drivers/net/tulip/winbond-840.c         |    2 --
 drivers/net/typhoon.c                   |    3 ---
 drivers/net/ucc_geth_ethtool.c          |    2 --
 drivers/net/via-rhine.c                 |    2 --
 drivers/net/xen-netfront.c              |    3 ---
 net/bridge/br_device.c                  |    3 ---
 net/core/ethtool.c                      |   32 +++++++++++++++++------=
---------
 38 files changed, 18 insertions(+), 112 deletions(-)
