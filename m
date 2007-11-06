From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: Please pull 'upstream-jgarzik' branch of wireless-2.6
Date: Mon, 5 Nov 2007 20:16:27 -0500
Message-ID: <20071106011627.GB23747@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Jeff,

Here is a slew of patches targeted for 2.6.25.  There are a bunch
of rt2x00, iwl3945, iwl4965, b43, and b43legacy patches, as well as
a few others.  I'm sorry I didn't spread this out better -- I got a
bit behind... :-(

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/upstream-jgarzik/

---

The following changes since commit 5d66f151ac7cb5162f201fe2996c6e01f0323f37:
  Linus Torvalds (1):
        Merge master.kernel.org:/.../gregkh/pci-2.6

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream-jgarzik

Adam Baker (2):
      rt2x00: Unconstify rt2x00dev
      rt2x00: Place mutex around USB register access

Christoph Hellwig (3):
      iwlwifi: mark more functions/variables static
      iwlwifi: keep 3945 and 4965 headers separate
      iwlwifi: cleanup Kconfig and ifdefs to split 3945 and 4965

Dan Williams (1):
      orinoco: more reliable scan handling

Dmitry Torokhov (1):
      P54: use temporary variables to reduce size of generated code

Emmanuel Grumbach (3):
      iwlwifi-ht: move 4965 SCD registers to iwl-prph.h
      iwlwifi: move 3945 SCD registers to iwl-prph.h
      iwlwifi: add 5965 SCD registers to iwl-prph.h

Holger Schurig (1):
      libertas: move wlan_*_association_work from header to c file

Ian Schram (5):
      iwlwifi: fix various spelling and typos
      iwlwifi: rename iwl_eeprom_aqcuire_semaphore to _acquire_
      iwlwifi: Two comments in iwl-3945.c were longer than 80 columns
      iwlwifi: Beautify by removing superfluous newlines and code
      iwlwifi: remove late null-check and duplicate bug_on

Ivo van Doorn (15):
      rt2x00: Move quality statistics into seperate structure
      rt2x00: Use enum defines
      rt2x00: Correctly translate mac80211 antenna setup to rt2x00
      rt2x00: SW diversity should default to antenna B
      rt2x00: Remove rt2x00_clear_link
      rt2x00: Implement SW diversity
      rt2x00: Cleanup if-statements
      rt2x00: Release rt2x00 2.0.11
      rt2x00: Disable RX when switching antenna
      rt2x00: Split rt61/rt73 antenna selection into RX and TX antenna
      rt2x00: Input-polldev requires input device
      rt2x00: Detect initial rfkill state on register
      rt2x00: Remove unused variables
      rt2x00: Remove data_desc structure
      rt2x00: Release rt2x00 2.0.12

Jes Sorensen (1):
      iwlwifi: disable interrupts before calling request_irq

Larry Finger (4):
      b43legacy: LED triggers support
      b43legacy: RF-kill support
      b43legacy: Use input-polldev for the rfkill switch
      b43legacy: Rewrite pwork locking

Matthias Kaehlcke (1):
      Prism54: Convert mgmt_sem to the mutex API

Mattias Nissler (4):
      rt2x00: Fix antenna selection.
      rt2x00: Rework rt61 antenna selection.
      rt2x00: Rework rt73 antenna selection
      rt2x00: Correctly set ACK bit in tx descriptors

Michael Buesch (7):
      b43legacy: Remove set_key callback
      b43: Dereference of wl->current_dev must be protected by wl->mutex
      b43: Use the retry limit parameters from mac80211
      b43: consistent naming for ieee80211_ops
      b43: Fix rfkill callback deadlock
      b43: debugfs SHM read buffer overrun fix
      b43: Rewrite and fix rfkill init

Roel Kluin (1):
      wireless: fix '!x & y' typo's

Tomas Winkler (11):
      iwlwifi: Add erp_ie_changed hanlder
      iwlwifi: renaming last_used and first_empty
      iwlwifi: rs-4965 fix return values
      iwlwifi: add TGN flag to qos parameters
      iwlwifi: remove cck_flag from iwl_driver_hw_info
      iwlwifi: remove cck_power_index_compensation
      iwlwifi: using PCI_DEVICE macro
      iwlwifi: replace restricted_reg with prph
      iwlwifi: rename restricted_mem to targ_mem
      iwlwifi: replacing wording restricted to nic access in iwl-io
      iwlwifi: Renames struct fw_image_desc to struct fw_desc

Zhu Yi (2):
      iwlwifi: Update iwlwifi version stamp to 1.1.18
      iwlwifi: Update iwlwifi version stamp to 1.1.19

mabbas (2):
      iwlwifi: accept up to 4K frame size on Rx side to fit A-MSDU frame
      iwl4965: exclude 60M rate from probe request

 drivers/net/wireless/Makefile                      |    3 +-
 drivers/net/wireless/airo.c                        |    2 +-
 drivers/net/wireless/atmel.c                       |    2 +-
 drivers/net/wireless/b43/debugfs.c                 |    2 +-
 drivers/net/wireless/b43/main.c                    |  159 ++--
 drivers/net/wireless/b43/rfkill.c                  |  115 +--
 drivers/net/wireless/b43/rfkill.h                  |   14 +-
 drivers/net/wireless/b43/xmit.c                    |    3 +-
 drivers/net/wireless/b43legacy/Kconfig             |   12 +
 drivers/net/wireless/b43legacy/Makefile            |   29 +-
 drivers/net/wireless/b43legacy/b43legacy.h         |   11 +-
 drivers/net/wireless/b43legacy/leds.c              |  413 ++++-----
 drivers/net/wireless/b43legacy/leds.h              |   61 +-
 drivers/net/wireless/b43legacy/main.c              |  214 ++---
 drivers/net/wireless/b43legacy/radio.c             |   15 +-
 drivers/net/wireless/b43legacy/radio.h             |    2 +-
 drivers/net/wireless/b43legacy/rfkill.c            |  185 ++++
 drivers/net/wireless/b43legacy/rfkill.h            |   59 ++
 drivers/net/wireless/iwlwifi/Kconfig               |  169 ++--
 .../{iwl-commands.h => iwl-3945-commands.h}        |  275 +-----
 .../iwlwifi/{iwl-debug.h => iwl-3945-debug.h}      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-3945-hw.h         |  629 ++++++++++++-
 .../wireless/iwlwifi/{iwl-io.h => iwl-3945-io.h}   |  289 +++---
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c         |    8 +-
 drivers/net/wireless/iwlwifi/iwl-3945-rs.h         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-3945.c            |  182 ++--
 drivers/net/wireless/iwlwifi/iwl-3945.h            |  963 ++++++++++++++++++-
 .../{iwl-commands.h => iwl-4965-commands.h}        |  154 +---
 .../iwlwifi/{iwl-debug.h => iwl-4965-debug.h}      |    6 +-
 drivers/net/wireless/iwlwifi/iwl-4965-hw.h         |  711 +++++++++++++-
 .../wireless/iwlwifi/{iwl-io.h => iwl-4965-io.h}   |  289 +++---
 drivers/net/wireless/iwlwifi/iwl-4965-rs.c         |  149 ++--
 drivers/net/wireless/iwlwifi/iwl-4965-rs.h         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-4965.c            |  305 +++---
 drivers/net/wireless/iwlwifi/iwl-4965.h            | 1035 +++++++++++++++++++-
 drivers/net/wireless/iwlwifi/iwl-channel.h         |  161 ---
 drivers/net/wireless/iwlwifi/iwl-eeprom.h          |  336 -------
 drivers/net/wireless/iwlwifi/iwl-hw.h              |  537 ----------
 drivers/net/wireless/iwlwifi/iwl-priv.h            |  308 ------
 drivers/net/wireless/iwlwifi/iwl-prph.h            |   53 +-
 drivers/net/wireless/iwlwifi/iwl3945-base.c        |  405 ++++----
 drivers/net/wireless/iwlwifi/iwl4965-base.c        |  529 +++++-----
 drivers/net/wireless/iwlwifi/iwlwifi.h             |  708 -------------
 drivers/net/wireless/libertas/assoc.h              |   18 -
 drivers/net/wireless/libertas/wext.c               |   52 +-
 drivers/net/wireless/orinoco.c                     |  541 ++++++-----
 drivers/net/wireless/orinoco.h                     |   12 +-
 drivers/net/wireless/p54common.c                   |    2 +-
 drivers/net/wireless/p54pci.c                      |   77 +-
 drivers/net/wireless/prism54/isl_ioctl.c           |    4 +-
 drivers/net/wireless/prism54/islpci_dev.c          |    2 +-
 drivers/net/wireless/prism54/islpci_dev.h          |    3 +-
 drivers/net/wireless/prism54/islpci_mgt.c          |    4 +-
 drivers/net/wireless/rt2x00/rt2400pci.c            |  104 ++-
 drivers/net/wireless/rt2x00/rt2400pci.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2500pci.c            |  112 ++--
 drivers/net/wireless/rt2x00/rt2500pci.h            |    4 +-
 drivers/net/wireless/rt2x00/rt2500usb.c            |  169 +++--
 drivers/net/wireless/rt2x00/rt2500usb.h            |   17 +-
 drivers/net/wireless/rt2x00/rt2x00.h               |  192 +++-
 drivers/net/wireless/rt2x00/rt2x00config.c         |   95 ++-
 drivers/net/wireless/rt2x00/rt2x00debug.h          |    4 +-
 drivers/net/wireless/rt2x00/rt2x00dev.c            |  212 ++++-
 drivers/net/wireless/rt2x00/rt2x00lib.h            |    2 +
 drivers/net/wireless/rt2x00/rt2x00pci.c            |    4 +-
 drivers/net/wireless/rt2x00/rt2x00pci.h            |    8 +-
 drivers/net/wireless/rt2x00/rt2x00rfkill.c         |   44 +-
 drivers/net/wireless/rt2x00/rt2x00ring.h           |   23 +-
 drivers/net/wireless/rt2x00/rt2x00usb.c            |   38 +-
 drivers/net/wireless/rt2x00/rt2x00usb.h            |   19 +-
 drivers/net/wireless/rt2x00/rt61pci.c              |  332 ++++---
 drivers/net/wireless/rt2x00/rt61pci.h              |   14 +-
 drivers/net/wireless/rt2x00/rt73usb.c              |  198 +++--
 drivers/net/wireless/rt2x00/rt73usb.h              |   14 +-
 drivers/net/wireless/zd1211rw/zd_rf_uw2453.c       |    2 +-
 net/ieee80211/ieee80211_wx.c                       |    2 +-
 76 files changed, 6655 insertions(+), 5189 deletions(-)
 create mode 100644 drivers/net/wireless/b43legacy/rfkill.c
 create mode 100644 drivers/net/wireless/b43legacy/rfkill.h
 copy drivers/net/wireless/iwlwifi/{iwl-commands.h => iwl-3945-commands.h} (86%)
 copy drivers/net/wireless/iwlwifi/{iwl-debug.h => iwl-3945-debug.h} (97%)
 copy drivers/net/wireless/iwlwifi/{iwl-io.h => iwl-3945-io.h} (50%)
 rename drivers/net/wireless/iwlwifi/{iwl-commands.h => iwl-4965-commands.h} (93%)
 rename drivers/net/wireless/iwlwifi/{iwl-debug.h => iwl-4965-debug.h} (97%)
 rename drivers/net/wireless/iwlwifi/{iwl-io.h => iwl-4965-io.h} (50%)
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-channel.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-eeprom.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-hw.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwl-priv.h
 delete mode 100644 drivers/net/wireless/iwlwifi/iwlwifi.h

Omnibus patch available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/upstream-jgarzik.patch
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
