From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2017-04-07
Date: Fri, 07 Apr 2017 17:36:39 +0300
Message-ID: <87wpawe13c.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's a pull request for net-next, more info in the signed tag below.
Please let me know if there are any problems.

Kalle

The following changes since commit 9c28286b1b4b9bce6e35dd4c8a1265f03802a89a:

  decnet: Use TCP nagle macro instead of literal number in decnet (2017-03-=
07 14:07:55 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-04-07

for you to fetch changes up to 1aed89640a899cd695bbfc976a4356affa474646:

  mwifiex: apply radar flag (2017-04-05 15:54:52 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.12

Lots of bugfixes as usual but also some new features.

Major changes:

ath10k

* improve firmware download time for QCA6174 and QCA9377, especially
  helps resume time

ath9k_htc

* add support AirTies 1eda:2315 AR9271 device

rt2x00

* add support MT7620

mwifiex

* enable auto deep sleep mode for USB chipsets

brcmfmac

* add support for network namespaces (WIPHY_FLAG_NETNS_OK)

----------------------------------------------------------------
Alexandre Belloni (1):
      atmel: remove time_t usage

Amitkumar Karwar (2):
      mwifiex: send fewer channels to scan while connected
      mwifiex: enable auto deep sleep mode for USB chipsets

Arend Van Spriel (3):
      brcmfmac: add support to move wiphy instance into network namespace
      brcmfmac: restore bus state when enter_D3 fails
      brcmfmac: no need for d11inf instance in brcmf_pno_start_sched_scan()

Brian Norris (4):
      mwifiex: pcie: clean up error prints in mwifiex_pcie_reset_notify()
      mwifiex: fix kernel crash after shutdown command timeout
      mwifiex: fix use-after-free for FW reinit errors
      mwifiex: catch mwifiex_fw_dpc() errors properly in reset

Christophe Jaillet (1):
      wcn36xx: Fix error handling

Colin Ian King (5):
      rtlwifi: fix spelling mistake: "conuntry" -> "country"
      ath10k: remove redundant error check
      ath10k: remove redundant check of len with buf_len
      ipw2200: remove redundant check of rc < 0
      wlcore: fix spelling mistakes in wl1271_warning

Daniel Golle (1):
      rt2x00: fix TX_PWR_CFG_4 register definition

Daniel Mentz (1):
      mwifiex: Use accessors routines for unaligned values

Dedy Lansky (4):
      wil6210: use print_hex_dump_debug instead of print_hex_dump_bytes
      wil6210: store bss object and use cfg80211_connect_bss()
      wil6210: use WMI_DISCONNECT_CMDID upon connect timeout
      wil6210: correctly report locally generated disconnect in STA mode

Devidas Puranik (1):
      mwifiex: fix for unaligned reads

Dmitry Tunin (1):
      ath9k_htc: Add support of AirTies 1eda:2315 AR9271 device

Franky Lin (7):
      brcmfmac: move brcmf_txflowblock to bcdc layer
      brcmfmac: move brcmf_txcomplete to bcdc layer
      brcmfmac: wrap brcmf_fws_add_interface into bcdc layer
      brcmfmac: wrap brcmf_fws_del_interface into bcdc layer
      brcmfmac: wrap brcmf_fws_reset_interface into bcdc layer
      brcmfmac: wrap brcmf_fws_init into bcdc layer
      brcmfmac: move brcmf_fws_deinit to bcdc layer

Gabor Juhos (1):
      rt2x00: rt2800lib: move rt2800_drv_data declaration into rt2800lib.h

Ganapathi Bhat (1):
      mwifiex: Support USB interrupt endpoint for command response/event

Hamad Kadmany (2):
      wil6210: set dma mask to reflect device capability
      wil6210: protect list of pending wmi events during flush

Hans de Goede (3):
      brcmfmac: Do not print the firmware version as an error
      brcmfmac: Do not complain about country code "00"
      brcmfmac: Handle status =3D=3D BRCMF_E_STATUS_ABORT in cfg80211_escan=
_handler

Jeffy Chen (1):
      mwifiex: wake system up when receives a wake irq

Johan Hovold (1):
      zd1211rw: fix NULL-deref at probe

Kalle Valo (2):
      ath10k: fix warnings from an earlier commit
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git

Karthik Ananthapadmanabha (3):
      mwifiex: add qualifier to firmware structures
      mwifiex: add missing IEs related to TDLS operation
      mwifiex: apply radar flag

Larry Finger (1):
      rtlwifi: Add code to read new versions of firmware

Lior David (3):
      wil6210: do not start regular scan on stopped p2p device
      wil6210: bus_request platform operation refinement
      wil6210: add oob_mode for AP certification

Maya Erez (1):
      wil6210: missing reinit_completion in HALP voting

Mohammed Shafi Shajakhan (4):
      ath10k: fix a warning during channel switch with multiple vaps
      ath10k: disallow DFS simulation if DFS channel is not enabled
      ath10k: fix fetching channel during potential radar detection
      ath10k: fix typo in wmi header file

Nils Holland (1):
      rtl8187: Enable monitor mode to fix multicast reception

Ping-Ke Shih (3):
      rtlwifi: Update 8821ae new phy parameters and its parser.
      rtlwifi: Update 8812ae new phy parameters and its parser.
      rtlwifi: Add QoS-NULL and BT-QoS-NULL to reserved page.

Rafa=C5=82 Mi=C5=82ecki (6):
      bcma: gpio: set of_node regardless of the host type
      bcma: drop unneeded check for CONFIG_OF_IRQ
      bcma: use helper function to set core dev's parent
      bcma: fill core OF info independently of bus type
      brcmfmac: always print error when PSM's watchdog fires
      brcmfmac: update BRCMFMAC symbol description

Roman Yeryomin (1):
      rt2x00: add support for MT7620

Rostyslav Khudolii (1):
      ath6kl: Remove old 802.11a-only channels

Ryan Hsu (2):
      ath10k: improve the firmware download time for QCA6174
      ath10k: improve the firmware download time for QCA9377

Stanislaw Gruszka (9):
      rt2800: identify station based on status WCID
      rt2x00: separte filling tx status from rt2x00lib_txdone
      rt2x00: separte clearing entry from rt2x00lib_txdone
      rt2x00: add txdone nomatch function
      rt2x00: fixup fill_tx_status for nomatch case
      rt2x00: use txdone_nomatch on rt2800usb
      rt2800: status based rate flags for nomatch case
      rt2800: use TXOP_BACKOFF for probe frames
      rt2x00: fix rt2x00debug_dump_frame comment

Tamizh chelvam (1):
      ath10k: update available channel list for 5G radio

Yan-Hsuan Chuang (12):
      rtlwifi: btcoex: remove unused functions
      rtlwifi: btcoex: follow linux coding style
      rtlwifi: btcoex: 23b 2ant: add btc8723b2ant_limited_rx to reduce agg =
size
      rtlwifi: btcoex: 23b 2ant: detect if bt is slave, and modify tdma
      rtlwifi: btcoex: 23b 2ant: monitor wifi counter for allocate tdma time
      rtlwifi: btcoex: 23b 2ant: less sensitive to tx rate penalty
      rtlwifi: btcoex: 23b 2ant: adjust wifi duration for bt a2dp
      rtlwifi: btcoex: 23b 2ant: coex table fine tune
      rtlwifi: btcoex: 23b 2ant: remove redundant bt stack report
      rtlwifi: btcoex: 23b 2ant: finer bt power adjustment
      rtlwifi: btcoex: 23b 2ant: add comments to describe how duration adju=
sted
      rtlwifi: btcoex: 23b 2ant: new fw use h2c to control GNT_BT

Zefir Kurtisi (1):
      ath9k: don't trigger spectral scan when not enabled

 drivers/bcma/driver_gpio.c                         |    3 +-
 drivers/bcma/main.c                                |   10 +-
 drivers/net/wireless/ath/ath10k/bmi.c              |   72 +
 drivers/net/wireless/ath/ath10k/bmi.h              |    2 +
 drivers/net/wireless/ath/ath10k/core.c             |    8 +-
 drivers/net/wireless/ath/ath10k/core.h             |    2 +
 drivers/net/wireless/ath/ath10k/debug.c            |   12 +-
 drivers/net/wireless/ath/ath10k/hw.c               |  265 +++
 drivers/net/wireless/ath/ath10k/hw.h               |   69 +
 drivers/net/wireless/ath/ath10k/mac.c              |   21 +-
 drivers/net/wireless/ath/ath10k/pci.c              |    6 -
 drivers/net/wireless/ath/ath10k/wmi.c              |   11 +
 drivers/net/wireless/ath/ath10k/wmi.h              |    4 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |    6 +-
 drivers/net/wireless/ath/ath9k/common-spectral.c   |    3 +
 drivers/net/wireless/ath/ath9k/hif_usb.c           |    1 +
 drivers/net/wireless/ath/wcn36xx/main.c            |    4 +-
 drivers/net/wireless/ath/wil6210/cfg80211.c        |   68 +-
 drivers/net/wireless/ath/wil6210/main.c            |   75 +-
 drivers/net/wireless/ath/wil6210/pcie_bus.c        |   16 +
 drivers/net/wireless/ath/wil6210/pmc.c             |   17 +-
 drivers/net/wireless/ath/wil6210/txrx.c            |   19 +-
 drivers/net/wireless/ath/wil6210/wil6210.h         |   21 +-
 drivers/net/wireless/ath/wil6210/wmi.c             |   21 +-
 drivers/net/wireless/atmel/atmel.c                 |    2 +-
 drivers/net/wireless/broadcom/brcm80211/Kconfig    |   10 +-
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    |   59 +
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.h    |    3 +
 .../net/wireless/broadcom/brcm80211/brcmfmac/bus.h |    5 -
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         |   10 +-
 .../wireless/broadcom/brcm80211/brcmfmac/common.c  |    2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |   66 +-
 .../wireless/broadcom/brcm80211/brcmfmac/debug.c   |   26 +-
 .../wireless/broadcom/brcm80211/brcmfmac/debug.h   |   18 +
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |    6 +-
 .../wireless/broadcom/brcm80211/brcmfmac/pcie.c    |    1 +
 .../net/wireless/broadcom/brcm80211/brcmfmac/pno.c |    2 -
 .../wireless/broadcom/brcm80211/brcmfmac/proto.h   |   36 +
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |    8 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/usb.c |    7 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c       |    3 -
 drivers/net/wireless/marvell/mwifiex/11h.c         |    3 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c    |   19 +
 drivers/net/wireless/marvell/mwifiex/cmdevt.c      |    4 +-
 drivers/net/wireless/marvell/mwifiex/fw.h          |   36 +-
 drivers/net/wireless/marvell/mwifiex/ie.c          |   15 +-
 drivers/net/wireless/marvell/mwifiex/ioctl.h       |    2 +
 drivers/net/wireless/marvell/mwifiex/main.c        |   37 +-
 drivers/net/wireless/marvell/mwifiex/main.h        |    2 +-
 drivers/net/wireless/marvell/mwifiex/pcie.c        |   65 +-
 drivers/net/wireless/marvell/mwifiex/scan.c        |   37 +-
 drivers/net/wireless/marvell/mwifiex/sdio.c        |   32 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmd.c     |   52 +-
 drivers/net/wireless/marvell/mwifiex/sta_cmdresp.c |    4 +-
 drivers/net/wireless/marvell/mwifiex/sta_event.c   |    8 +-
 drivers/net/wireless/marvell/mwifiex/tdls.c        |   59 +-
 drivers/net/wireless/marvell/mwifiex/uap_event.c   |    2 +-
 drivers/net/wireless/marvell/mwifiex/usb.c         |   45 +-
 drivers/net/wireless/marvell/mwifiex/usb.h         |    8 +-
 drivers/net/wireless/marvell/mwifiex/util.c        |    6 +-
 drivers/net/wireless/marvell/mwifiex/util.h        |    5 +
 drivers/net/wireless/ralink/rt2x00/Kconfig         |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800.h        |  212 +-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.c     | 1490 +++++++++++-
 drivers/net/wireless/ralink/rt2x00/rt2800lib.h     |   31 +-
 drivers/net/wireless/ralink/rt2x00/rt2800mmio.c    |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c     |   18 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00.h        |    5 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00dev.c     |  232 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00queue.c   |    7 +-
 drivers/net/wireless/ralink/rt2x00/rt2x00queue.h   |    4 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c |   16 +-
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.c    | 2468 ++++++++--------=
----
 .../realtek/rtlwifi/btcoexist/halbtc8192e2ant.h    |   24 +-
 .../realtek/rtlwifi/btcoexist/halbtc8723b1ant.c    | 1005 +-------
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.c    | 1655 ++++---------
 .../realtek/rtlwifi/btcoexist/halbtc8723b2ant.h    |   18 +-
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.c    | 1470 +++++-------
 .../realtek/rtlwifi/btcoexist/halbtc8821a1ant.h    |    2 +-
 .../realtek/rtlwifi/btcoexist/halbtc8821a2ant.c    | 2306 ++++++----------=
--
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.c       |    2 +-
 .../realtek/rtlwifi/btcoexist/halbtcoutsrc.h       |    3 +-
 drivers/net/wireless/realtek/rtlwifi/regd.c        |    2 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.c    |   64 +-
 .../net/wireless/realtek/rtlwifi/rtl8192ee/fw.h    |    4 +
 .../net/wireless/realtek/rtlwifi/rtl8192ee/hw.c    |    4 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.c    |   69 +-
 .../net/wireless/realtek/rtlwifi/rtl8723be/fw.h    |    4 +
 .../net/wireless/realtek/rtlwifi/rtl8723be/sw.c    |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.c    |  165 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/fw.h    |    2 +
 .../net/wireless/realtek/rtlwifi/rtl8821ae/hw.c    |    8 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/phy.c   |  385 ++-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/sw.c    |   15 +-
 .../net/wireless/realtek/rtlwifi/rtl8821ae/table.c | 1858 +++++----------
 .../net/wireless/realtek/rtlwifi/rtl8821ae/table.h |   28 +-
 drivers/net/wireless/realtek/rtlwifi/wifi.h        |   18 +
 drivers/net/wireless/ti/wlcore/debugfs.c           |    2 +-
 drivers/net/wireless/zydas/zd1211rw/zd_usb.c       |    3 +
 99 files changed, 6865 insertions(+), 8194 deletions(-)

--=20
Kalle Valo
