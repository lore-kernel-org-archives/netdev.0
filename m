From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Tue, 4 Dec 2007 08:59:25 -0500
Message-ID: <20071204135925.GB19911@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2982 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754816AbXLDN7r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 08:59:47 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

Here are more than 5 score patches intended for 2.6.25.  This request
replaces the request sent on 27 November. [1]

There are tons of updates here, especially iwlwifi and libertas.  The
b43, b43legacy, rt2x00, rtl8187, and zd1211rw drivers are also updated.

This pull contains the port of zd1211rw to the mac80211 infrastructure.
There is also some SSB stuff in there.  I've been sending that stuff
to Dave M., but since later b43 patches depend on it I thought it
would be better to send them your way.  I'll CC Dave.

Also included is the iwl4965 work to use the .11n stuff that has been
added in the net-2.6.25 tree.  For now I've added a "depends on n" to
the IWL4965_HT Kconfig to avoid build breakage in your tree.

The total diff is getting big -- the patch is nearing 2MB.  Please let
me know if there are any problems so we can get (at least some of)
this merged!

Thanks,

John

[1] http://marc.info/?l=3Dlinux-netdev&m=3D119617493212177&w=3D2

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/up=
stream-jgarzik

---

The following changes since commit e86d91426d8b3d79010c9d5c617d7594e5c1=
65aa:
  Jeff Garzik (1):
        Merge branch 'r6040' of git://git.kernel.org/.../romieu/netdev-=
2.6 into upstream

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.g=
it upstream-jgarzik

Andrea Merello (1):
      rtl8187: fix tx power reading

Andres Salomon (4):
      libertas: drop useless default_fw_name variable
      libertas: mark module_init/exit functions as __init/__exit
      libertas: reset devices upon disconnect rather than module unload=
ing
      libertas: nuke useless variable usbdriver_name and useless commen=
ts

Ben M Cahill (29):
      iwl3945: re-align 3945 event log data
      iwl4965: add comments to rate scaling code
      iwlwifi: add comments to EEPROM stuff
      iwl-4965-hw.h: clean up unused eeprom structures and definitions
      iwlwifi: clean up and clarify some comments after 3945/4965 split
      iwlwifi: Move is_legacy() macro family from iwl-4965-hw.h to iwl-=
4965-rs.h
      iwlwifi: Add comments to some driver data structures
      iwlwifi: Document 4965 rate_n_flags bits
      iwlwifi: Document Rx calibration
      iwlwifi: Partially clean-up, add comments to iwl-*-hw.h
      iwlwifi: clean up some unused definitions in iwl-4965.h and iwl-3=
945.h
      iwlwifi: add comments, mostly on Tx queues
      iwlwifi: add comments to iwl*-base.c
      iwlwifi: Clean up unused definitions in iwl-3945-hw.h
      iwlwifi: clean up unused definitions in iwl-4965-hw.h
      iwlwifi: move uCode API definitions to iwl-4965-commands.h
      iwlwifi: move HT_IE_EXT_CHANNEL_* driver definitions to iwl-4965.=
h
      iwlwifi: document temperature calculation
      iwlwifi: document txpower calculations
      iwlwifi: document keep-warm buffer
      iwlwifi: document Rx registers
      iwlwifi: document Tx registers
      iwlwifi: document shared Tx structures
      iwlwifi: document 4965 Tx scheduler
      iwlwifi: document command header and "alive" responses
      iwlwifi: add comments to RXON command and txpower formats
      iwlwifi: add comments to QOS and ADD_STA commands
      iwlwifi: add comments to Tx commands
      iwlwifi: document 4965 rate scaling

Brajesh Dave (2):
      libertas: separate mesh connectivity from that of the main interf=
ace
      libertas: configurable beacon interval

Christoph Hellwig (1):
      iwlwifi: cleanup namespace

Daniel Drake (3):
      zd1211rw: port to mac80211
      zd1211rw: Add ID for Trendnet TEW-429UB A
      zd1211rw: add copyright notices

=46rank Lichtenheld (2):
      b43: silence a bogus gcc warning
      b43legacy: properly fix a bogus gcc warning

Holger Schurig (9):
      libertas: move to uniform lbs_/LBS_ namespace
      libertas: clean up association debug messages
      libertas: remove arbitrary typedefs
      libertas: rework event subscription
      libertas: tweak association debug output
      libertas: tweak tx path debugging
      libertas: remove numprobes
      libertas: remove user-specified channel list
      libertas: less eventcause shifts

Ivo van Doorn (10):
      rt2x00: Move duplicate code into rt2x00pci_txdone()
      rt2x00: Replace DRV_NAME with KBUILD_MODNAME
      rt2x00: Extend PLCP descriptor definition for rt2400pci
      rt2x00: Move register value/offset files into new folder
      rt2x00: Add chipset version to chipset debugfs entry
      rt2x00: Add skb descriptor
      rt2x00: Add TX/RX frame dumping facility
      rt2x00: Use IEEE80211_IF_TYPE_INVALID directly
      rt2x00: Cleanup rfkill
      rt2x00: Release rt2x00 2.0.13

Johannes Berg (3):
      b43: include full 64-bit timestamp in monitor mode
      b43: include FCS in frames handed to mac80211
      b43legacy: include full 64-bit timestamp in monitor mode

John W. Linville (1):
      iwlwifi: remove redundant initialization of final_mode

Larry Finger (8):
      ssb: Add new SPROM structure while keeping the old
      ssb: Convert to use of the new SPROM structure
      b44: Convert to use of the new SPROM structure
      b43: Convert to use of the new SPROM structure
      b43legacy: Convert to use of the new SPROM structure
      ssb: Remove the old, now unused, data structures
      b43: Changes to enable BCM4311 rev 02 with wireless core revision=
 13
      rt2x00: Remove redundant code in rfkill setup

Matthias Mueller (1):
      rtl8187: Add USB ID for Sitecom WL-168 v1 001

Mattias Nissler (2):
      rt2x00: Allow rt61 to catch up after a missing tx report
      rt2x00: Only update rssi average approximation on receiving beaco=
n frames.

Miguel Bot=F3n (1):
      iwlwifi: remove redundant declaration of 'iwl3945_priv' and 'iwl4=
965_priv' structs

Mohamed Abbas (4):
      iwl4965: fix cannot find a suitable rate issue
      iwlwifi: enhance WPA authenication stability
      iwlwifi: fix ucode assertion for RX queue overrun
      iwlwifi: avoid firmware command sending if rfkill is enabled

Reinette Chatre (2):
      MAINTAINERS: Add Reinette Chatre to iwlwifi & ipw2100/ipw2200
      iwlwifi: continue namespace changes - fix CONFIG variables

Ron Rindjunsky (8):
      iwlwifi: 802.11n remove unnecessary config dependency
      iwlwifi: 802.11n new framework structures preperation
      iwlwifi: 802.11n configuring hw_mode parameters to support HT in =
A/G
      iwlwifi: 802.11n handling probe request HT IE
      iwlwifi: 802.11n comply HT self configuration flow with mac80211 =
framework
      iwlwifi: 802.11n comply HT add station flow with mac80211 framewo=
rk
      iwlwifi: 802.11n comply HT rate scaling flows with mac80211 frame=
work
      iwlwifi: 802.11n add support to 8K A-MSDU Rx frames

Stefano Brivio (8):
      b43legacy: use the retry limits provided by mac80211
      b43legacy: use a consistent naming scheme for the ops
      b43legacy: rewrite and fix rfkill initialization
      b43: rewrite A PHY initialization
      b43/b43legacy: fix my copyright notices
      b43legacy: fix kconfig dependecies for rfkill and leds
      b43: reinit on too many PHY TX errors
      b43legacy: reinit on too many PHY TX errors

Tomas Winkler (1):
      iwlwifi: Support for uCode without init and bsm section

Ulrich Kunitz (1):
      zd1211rw: Fix alignment problems

Zhu Yi (5):
      iwlwifi: replace 0x8086 with PCI_VENDOR_ID_INTEL
      remove unused iwl4965_init_hw_rates function
      iwl4965: fix rxon flags set to wrong value for A mode in .erp_ie_=
changed
      iwlwifi: update version number to 1.2.22
      iwlwifi: cache mac80211 conf setting during a hardware scan

 MAINTAINERS                                      |   10 +-
 drivers/net/b44.c                                |    8 +-
 drivers/net/wireless/b43/Makefile                |    1 +
 drivers/net/wireless/b43/b43.h                   |   11 +
 drivers/net/wireless/b43/debugfs.c               |    2 +-
 drivers/net/wireless/b43/dma.c                   |   32 +-
 drivers/net/wireless/b43/leds.c                  |   10 +-
 drivers/net/wireless/b43/lo.c                    |    8 +-
 drivers/net/wireless/b43/main.c                  |   62 +-
 drivers/net/wireless/b43/main.h                  |    2 +-
 drivers/net/wireless/b43/phy.c                   |  672 +----
 drivers/net/wireless/b43/phy.h                   |   18 +-
 drivers/net/wireless/b43/tables.c                |  103 +-
 drivers/net/wireless/b43/tables.h                |   12 +-
 drivers/net/wireless/b43/wa.c                    |  666 +++++
 drivers/net/wireless/b43/wa.h                    |    7 +
 drivers/net/wireless/b43/xmit.c                  |   23 +-
 drivers/net/wireless/b43legacy/Kconfig           |    8 +-
 drivers/net/wireless/b43legacy/b43legacy.h       |    7 +
 drivers/net/wireless/b43legacy/debugfs.c         |    2 +-
 drivers/net/wireless/b43legacy/ilt.c             |    2 +-
 drivers/net/wireless/b43legacy/leds.c            |   10 +-
 drivers/net/wireless/b43legacy/main.c            |  172 +-
 drivers/net/wireless/b43legacy/main.h            |    2 +-
 drivers/net/wireless/b43legacy/phy.c             |   40 +-
 drivers/net/wireless/b43legacy/phy.h             |    2 +-
 drivers/net/wireless/b43legacy/radio.c           |   14 +-
 drivers/net/wireless/b43legacy/radio.h           |    2 +-
 drivers/net/wireless/b43legacy/rfkill.c          |   16 +-
 drivers/net/wireless/b43legacy/rfkill.h          |    8 +-
 drivers/net/wireless/b43legacy/xmit.c            |   25 +-
 drivers/net/wireless/iwlwifi/Kconfig             |   31 +-
 drivers/net/wireless/iwlwifi/iwl-3945-commands.h |  586 +++--
 drivers/net/wireless/iwlwifi/iwl-3945-debug.h    |   12 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h       |  353 ++--
 drivers/net/wireless/iwlwifi/iwl-3945-io.h       |  256 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c       |  146 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h       |   37 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c          |  553 ++--
 drivers/net/wireless/iwlwifi/iwl-3945.h          |  445 ++--
 drivers/net/wireless/iwlwifi/iwl-4965-commands.h | 1394 ++++++++--
 drivers/net/wireless/iwlwifi/iwl-4965-debug.h    |   12 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h       | 2139 ++++++++++----=
-
 drivers/net/wireless/iwlwifi/iwl-4965-io.h       |  256 +-
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c       |  869 +++++--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h       |   87 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c          | 1136 +++++---
 drivers/net/wireless/iwlwifi/iwl-4965.h          |  641 +++---
 drivers/net/wireless/iwlwifi/iwl-prph.h          |   14 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c      | 2776 ++++++++++----=
-----
 drivers/net/wireless/iwlwifi/iwl4965-base.c      | 3241 +++++++++++---=
--------
 drivers/net/wireless/libertas/11d.c              |   72 +-
 drivers/net/wireless/libertas/11d.h              |   26 +-
 drivers/net/wireless/libertas/README             |   40 +-
 drivers/net/wireless/libertas/assoc.c            |  265 +-
 drivers/net/wireless/libertas/assoc.h            |   14 +-
 drivers/net/wireless/libertas/cmd.c              |  354 ++-
 drivers/net/wireless/libertas/cmdresp.c          |  238 +-
 drivers/net/wireless/libertas/debugfs.c          | 1375 ++-------
 drivers/net/wireless/libertas/debugfs.h          |   12 +-
 drivers/net/wireless/libertas/decl.h             |  116 +-
 drivers/net/wireless/libertas/defs.h             |   52 +-
 drivers/net/wireless/libertas/dev.h              |   45 +-
 drivers/net/wireless/libertas/ethtool.c          |   52 +-
 drivers/net/wireless/libertas/host.h             |   70 +-
 drivers/net/wireless/libertas/hostcmd.h          |   26 +-
 drivers/net/wireless/libertas/if_cs.c            |   45 +-
 drivers/net/wireless/libertas/if_sdio.c          |   51 +-
 drivers/net/wireless/libertas/if_sdio.h          |    4 +-
 drivers/net/wireless/libertas/if_usb.c           |  132 +-
 drivers/net/wireless/libertas/if_usb.h           |    7 +-
 drivers/net/wireless/libertas/join.c             |  202 +-
 drivers/net/wireless/libertas/join.h             |   38 +-
 drivers/net/wireless/libertas/main.c             |  563 ++--
 drivers/net/wireless/libertas/rx.c               |   68 +-
 drivers/net/wireless/libertas/scan.c             |  274 +--
 drivers/net/wireless/libertas/scan.h             |   96 +-
 drivers/net/wireless/libertas/tx.c               |   45 +-
 drivers/net/wireless/libertas/types.h            |   25 +-
 drivers/net/wireless/libertas/wext.c             |  487 ++--
 drivers/net/wireless/libertas/wext.h             |   14 +-
 drivers/net/wireless/rt2x00/rt2400pci.c          |   69 +-
 drivers/net/wireless/rt2x00/rt2400pci.h          |   20 +-
 drivers/net/wireless/rt2x00/rt2500pci.c          |   29 +-
 drivers/net/wireless/rt2x00/rt2500usb.c          |   39 +-
 drivers/net/wireless/rt2x00/rt2x00.h             |   26 +-
 drivers/net/wireless/rt2x00/rt2x00config.c       |    5 -
 drivers/net/wireless/rt2x00/rt2x00debug.c        |  240 ++-
 drivers/net/wireless/rt2x00/rt2x00dev.c          |   93 +-
 drivers/net/wireless/rt2x00/rt2x00dump.h         |  121 +
 drivers/net/wireless/rt2x00/rt2x00firmware.c     |    5 -
 drivers/net/wireless/rt2x00/rt2x00lib.h          |    6 +
 drivers/net/wireless/rt2x00/rt2x00mac.c          |    7 +-
 drivers/net/wireless/rt2x00/rt2x00pci.c          |   92 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h          |    4 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c       |   15 -
 drivers/net/wireless/rt2x00/rt2x00ring.h         |   22 +
 drivers/net/wireless/rt2x00/rt2x00usb.c          |   41 +-
 drivers/net/wireless/rt2x00/rt61pci.c            |   68 +-
 drivers/net/wireless/rt2x00/rt73usb.c            |   36 +-
 drivers/net/wireless/rtl8187_dev.c               |    2 +
 drivers/net/wireless/rtl8187_rtl8225.c           |    8 +-
 drivers/net/wireless/zd1211rw/Kconfig            |    7 +-
 drivers/net/wireless/zd1211rw/Makefile           |    3 +-
 drivers/net/wireless/zd1211rw/zd_chip.c          |  126 +-
 drivers/net/wireless/zd1211rw/zd_chip.h          |   60 +-
 drivers/net/wireless/zd1211rw/zd_def.h           |    5 +-
 drivers/net/wireless/zd1211rw/zd_ieee80211.c     |  196 +-
 drivers/net/wireless/zd1211rw/zd_ieee80211.h     |   49 +-
 drivers/net/wireless/zd1211rw/zd_mac.c           | 1535 ++++-------
 drivers/net/wireless/zd1211rw/zd_mac.h           |  117 +-
 drivers/net/wireless/zd1211rw/zd_netdev.c        |  264 --
 drivers/net/wireless/zd1211rw/zd_netdev.h        |   45 -
 drivers/net/wireless/zd1211rw/zd_rf.c            |    5 +-
 drivers/net/wireless/zd1211rw/zd_rf.h            |    5 +-
 drivers/net/wireless/zd1211rw/zd_rf_al2230.c     |    5 +-
 drivers/net/wireless/zd1211rw/zd_rf_al7230b.c    |    5 +-
 drivers/net/wireless/zd1211rw/zd_rf_rf2959.c     |    5 +-
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c     |    5 +-
 drivers/net/wireless/zd1211rw/zd_usb.c           |  289 ++-
 drivers/net/wireless/zd1211rw/zd_usb.h           |   36 +-
 drivers/ssb/b43_pci_bridge.c                     |    1 +
 drivers/ssb/main.c                               |   10 +-
 drivers/ssb/pci.c                                |  221 +-
 include/linux/ssb/ssb.h                          |   71 +-
 include/linux/ssb/ssb_regs.h                     |   59 +-
 126 files changed, 14163 insertions(+), 11658 deletions(-)
 create mode 100644 drivers/net/wireless/b43/wa.c
 create mode 100644 drivers/net/wireless/b43/wa.h
 create mode 100644 drivers/net/wireless/rt2x00/rt2x00dump.h
 delete mode 100644 drivers/net/wireless/zd1211rw/zd_netdev.c
 delete mode 100644 drivers/net/wireless/zd1211rw/zd_netdev.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/upstream-jgarzi=
k.patch.bz2
--=20
John W. Linville
linville@tuxdriver.com
