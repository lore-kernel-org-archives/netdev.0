From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-01-02
Date: Mon, 02 Jan 2017 15:20:59 +0200
Message-ID: <8760lxk37o.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

first pull request for 4.11. The tree is based on 4.9 but that shouldn't
be a problem, at least my test pull to net-next worked ok. I'll fast
forward my trees after you have pulled this.

Please let me know if you have any problems.

Kalle


The following changes since commit adc176c5472214971d77c1a61c83db9b01e9cdc7:

  ipv6 addrconf: Implemented enhanced DAD (RFC7527) (2016-12-03 23:21:37 -0=
500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-01-02

for you to fetch changes up to e16e558e83ed848f5dac3931dc7549d7a3090f7e:

  rtlwifi: fix spelling mistake: "encrypiton" -> "encryption" (2017-01-01 2=
0:54:33 +0200)

----------------------------------------------------------------
wireless-drivers-next patches for 4.11

The most notable change here is the inclusion of airtime fairness
scheduling to ath9k. It prevents slow clients from hogging all the
airtime and unfairly slowing down faster clients.

Otherwise smaller changes and cleanup.

Major changes:

ath9k

* cleanup eeprom endian handling
* add airtime fairness scheduling

ath10k

* fix issues for new QCA9377 firmware version
* support dev_coredump() for firmware crash dump
* enable channel 169 on 5 GHz band

----------------------------------------------------------------
Alexey Khoroshilov (1):
      adm80211: add checks for dma mapping errors

Amitkumar Karwar (3):
      mwifiex: sdio: fix use after free issue for save_adapter
      mwifiex: change width of MAC control variable
      mwifiex: Enable dynamic bandwidth signalling

Andrew Lutomirski (1):
      orinoco: Use shash instead of ahash for MIC calculations

Arun Khandavalli (1):
      ath10k: support dev_coredump for crash dump

Bartosz Markowski (5):
      ath10k: fix IRAM banks number for QCA9377
      ath10k: override CE5 config for QCA9377
      ath10k: decrease num of peers support
      ath10k: set CTS protection VDEV param only if VDEV is up
      ath10k: add debug trace to rts/cts set function

Bhumika Goyal (1):
      libertas: constify cfg80211_ops structures

Christian Lamparter (1):
      ath10k: fix potential memory leak in ath10k_wmi_tlv_op_pull_fw_stats()

Colin Ian King (4):
      rtlwifi: fix spelling mistake: "contry" -> "country"
      brcmfmac: fix spelling mistakes on "Ivalid"
      wlcore: fix spelling mistake in wl1271_warning
      rtlwifi: fix spelling mistake: "encrypiton" -> "encryption"

Dan Carpenter (2):
      mwifiex: clean up some messy indenting
      adm80211: return an error if adm8211_alloc_rings() fails

Johannes Berg (1):
      iwlegacy: make il3945_mac_ops __ro_after_init

Kalle Valo (1):
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Larry Finger (14):
      rtlwifi: Replace local debug macro RT_ASSERT
      rtlwifi: Remove RT_TRACE messages that use DBG_EMERG
      rtlwifi: rtl8821ae: Remove all instances of DBG_EMERG
      rtlwifi: rtl8723be: Remove all instances of DBG_EMERG
      rtlwifi: rtl8723ae: Remove all instances of DBG_EMERG
      rtlwifi: rtl8192ee: Remove all instances of DBG_EMERG
      rtlwifi: rtl8723-common: Remove all instances of DBG_EMERG
      rtlwifi: rtl8192se: Remove all instances of DBG_EMERG
      rtlwifi: rtl8192de: Remove all instances of DBG_EMERG
      rtlwifi: rtl8192cu: Remove all instances of DBG_EMERG
      rtlwifi: rtl8192ce: Remove all instances of DBG_EMERG
      rtlwifi: rtl8192c-common: Remove all instances of DBG_EMERG
      rtlwifi: rtl8188ee: Remove all instances of DBG_EMERG
      rtlwifi: Remove some redundant code

Martin Blumenstingl (7):
      ath9k: Add a #define for the EEPROM "eepmisc" endianness bit
      ath9k: indicate that the AR9003 EEPROM template values are little end=
ian
      ath9k: Add an eeprom_ops callback for retrieving the eepmisc value
      ath9k: replace eeprom_param EEP_MINOR_REV with get_eeprom_rev
      ath9k: consistently use get_eeprom_rev(ah)
      ath9k: Make the EEPROM swapping check use the eepmisc register
      ath9k: define all EEPROM fields in Little Endian format

Mohammed Shafi Shajakhan (3):
      ath10k: Avoid potential page alloc BUG_ON in tx free path
      ath10k: Remove passing unused argument for ath10k_mac_tx
      ath10k: enable advertising support for channel 169, 5Ghz

Ping-Ke Shih (1):
      rtlwifi: Fix alignment issues

Ryan Hsu (3):
      ath10k: fix incorrect txpower set by P2P_DEVICE interface
      ath10k: recal the txpower when removing interface
      ath10k: ignore configuring the incorrect board_id

Stanislaw Gruszka (11):
      rt2800: make rx ampdu_factor depend on number of rx chains
      rt2800: don't set ht parameters for non-aggregated frames
      rt2800: set minimum MPDU and PSDU lengths to sane values
      rt2800: set MAX_PSDU len according to remote STAs capabilities
      rt2800: rename adjust_freq_offset function
      rt2800: warn if doing VCO recalibration for unknow RF chip
      rt2800: perform VCO recalibration for RF5592 chip
      rt2x00: merge agc and vco works with link tuner
      rt2800: replace mdelay by usleep on vco calibration.
      rt2800: replace msleep() with usleep_range() on channel switch
      rt2x00: add mutex to synchronize config and link tuner

Toke H=C3=B8iland-J=C3=B8rgensen (2):
      ath9k: Introduce airtime fairness scheduling between stations
      ath9k: Turn ath_txq_lock/unlock() into static inlines.

 drivers/net/wireless/admtek/adm8211.c              |   27 ++-
 drivers/net/wireless/ath/ath10k/core.c             |   11 +-
 drivers/net/wireless/ath/ath10k/core.h             |    2 +-
 drivers/net/wireless/ath/ath10k/debug.c            |   43 ++++-
 drivers/net/wireless/ath/ath10k/debug.h            |    8 +
 drivers/net/wireless/ath/ath10k/htt_tx.c           |    2 +
 drivers/net/wireless/ath/ath10k/hw.h               |    2 +-
 drivers/net/wireless/ath/ath10k/mac.c              |   73 ++++++--
 drivers/net/wireless/ath/ath10k/pci.c              |    4 +-
 drivers/net/wireless/ath/ath10k/wmi-tlv.c          |   12 +-
 drivers/net/wireless/ath/ath9k/ar5008_phy.c        |    2 +-
 drivers/net/wireless/ath/ath9k/ar9002_hw.c         |    6 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |   21 ++-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.h     |    4 +-
 drivers/net/wireless/ath/ath9k/ath9k.h             |   36 +++-
 drivers/net/wireless/ath/ath9k/channel.c           |   14 +-
 drivers/net/wireless/ath/ath9k/debug.c             |    3 +
 drivers/net/wireless/ath/ath9k/debug.h             |   13 ++
 drivers/net/wireless/ath/ath9k/debug_sta.c         |   54 ++++++
 drivers/net/wireless/ath/ath9k/eeprom.c            |   42 +++--
 drivers/net/wireless/ath/ath9k/eeprom.h            |   85 +++++----
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |  137 ++++++--------
 drivers/net/wireless/ath/ath9k/eeprom_9287.c       |  129 ++++++-------
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |  163 ++++++++---------
 drivers/net/wireless/ath/ath9k/init.c              |    2 +
 drivers/net/wireless/ath/ath9k/main.c              |    6 +-
 drivers/net/wireless/ath/ath9k/recv.c              |   65 +++++++
 drivers/net/wireless/ath/ath9k/xmit.c              |  192 +++++++++++++---=
----
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |    4 +-
 drivers/net/wireless/intel/iwlegacy/3945-mac.c     |   20 +-
 drivers/net/wireless/intersil/orinoco/mic.c        |   44 +++--
 drivers/net/wireless/intersil/orinoco/mic.h        |    3 +-
 drivers/net/wireless/intersil/orinoco/orinoco.h    |    4 +-
 drivers/net/wireless/marvell/libertas/cfg.c        |    2 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   19 +-
 drivers/net/wireless/marvell/mwifiex/init.c        |    3 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |    2 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |    6 +
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |    8 +-
 drivers/net/wireless/ralink/rt2x00/rt2800.h        |    2 +
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     |   79 ++++++--
 drivers/net/wireless/ralink/rt2x00/rt2800lib.h     |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |    6 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |    7 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00lib.h     |   31 +---
 drivers/net/wireless/ralink/rt2x00/rt2x00link.c    |  132 ++++----------
 drivers/net/wireless/ralink/rt2x00/rt2x00mac.c     |    8 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00queue.c   |   12 +-
 drivers/net/wireless/realtek/rtlwifi/base.c        |   15 +-
 drivers/net/wireless/realtek/rtlwifi/cam.c         |   14 +-
 drivers/net/wireless/realtek/rtlwifi/core.c        |   31 ++--
 drivers/net/wireless/realtek/rtlwifi/debug.h       |   16 +-
 drivers/net/wireless/realtek/rtlwifi/efuse.c       |    3 +-
 drivers/net/wireless/realtek/rtlwifi/pci.c         |   48 ++---
 drivers/net/wireless/realtek/rtlwifi/ps.c          |    3 +-
 drivers/net/wireless/realtek/rtlwifi/rc.c          |    3 +-
 drivers/net/wireless/realtek/rtlwifi/regd.c        |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/fw.c    |   44 ++---
 .../net/wireless/realtek/rtlwifi/rtl8188ee/hw.c    |   33 ++--
 .../net/wireless/realtek/rtlwifi/rtl8188ee/phy.c   |   35 ++--
 .../net/wireless/realtek/rtlwifi/rtl8188ee/rf.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/sw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8188ee/trx.c   |    8 +-
 .../wireless/realtek/rtlwifi/rtl8192c/fw_common.c  |   46 ++---
 .../wireless/realtek/rtlwifi/rtl8192c/phy_common.c |   28 +--
 .../net/wireless/realtek/rtlwifi/rtl8192ce/hw.c    |   39 ++--
 .../net/wireless/realtek/rtlwifi/rtl8192ce/led.c   |    7 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/phy.c   |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/rf.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/sw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ce/trx.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/hw.c    |   35 ++--
 .../net/wireless/realtek/rtlwifi/rtl8192cu/led.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/mac.c   |   12 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/phy.c   |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/rf.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/sw.c    |    5 +-
 .../net/wireless/realtek/rtlwifi/rtl8192cu/trx.c   |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/fw.c    |   34 ++--
 .../net/wireless/realtek/rtlwifi/rtl8192de/hw.c    |   35 ++--
 .../net/wireless/realtek/rtlwifi/rtl8192de/led.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/phy.c   |   45 +++--
 .../net/wireless/realtek/rtlwifi/rtl8192de/rf.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/sw.c    |   10 +-
 .../net/wireless/realtek/rtlwifi/rtl8192de/trx.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |   40 +---
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/phy.c   |   39 ++--
 .../net/wireless/realtek/rtlwifi/rtl8192ee/rf.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/sw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/trx.c   |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/fw.c    |   46 ++---
 .../net/wireless/realtek/rtlwifi/rtl8192se/hw.c    |   43 ++---
 .../net/wireless/realtek/rtlwifi/rtl8192se/led.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/phy.c   |   45 ++---
 .../net/wireless/realtek/rtlwifi/rtl8192se/rf.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/sw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8192se/trx.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/fw.c    |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/hw.c    |   21 +--
 .../net/wireless/realtek/rtlwifi/rtl8723ae/led.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/phy.c   |   31 ++--
 .../net/wireless/realtek/rtlwifi/rtl8723ae/rf.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/sw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8723ae/trx.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.c    |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/hw.c    |   18 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/led.c   |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/phy.c   |   33 ++--
 .../net/wireless/realtek/rtlwifi/rtl8723be/rf.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/trx.c   |   14 +-
 .../realtek/rtlwifi/rtl8723com/fw_common.c         |   26 +--
 .../realtek/rtlwifi/rtl8723com/phy_common.c        |    6 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/dm.c    |    3 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |   28 +--
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |   33 ++--
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |   54 +++---
 .../net/wireless/realtek/rtlwifi/rtl8821ae/rf.c    |    5 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |   14 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/trx.c   |   20 +-
 drivers/net/wireless/realtek/rtlwifi/usb.c         |   48 ++---
 drivers/net/wireless/ti/wlcore/debugfs.c           |    2 +-
 123 files changed, 1487 insertions(+), 1421 deletions(-)
