From: Kalle Valo <kvalo@codeaurora.org>
Subject: pull-request: wireless-drivers-next 2017-08-28
Date: Mon, 28 Aug 2017 12:22:34 +0300
Message-ID: <87val8ujvp.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:36902 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751857AbdH1JWj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 05:22:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here's a pull request to net-next for 4.14. Because I pulled
wireless-drivers (at least that's my suspicion) the diffstat was wrong
again and I created it manually. I recall Linus somewhere saying that in
certain cases this is normal and it's ok to create the diffstat
manually, so I don't worry about this anymore.

In this pull request we also add SDIO_DEVICE_ID_CYPRESS_4373 to
include/linux/mmc/sdio_ids.h which stands out in the diffstat.

Please let me know if there are any problems.

Kalle

The following changes since commit e9bf53ab1ee34bb05c104bbfd2b77c844773f8e6:

  brcmfmac: feature check for multi-scheduled scan fails on bcm4343x device=
s (2017-08-14 11:09:30 +0300)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next=
.git tags/wireless-drivers-next-for-davem-2017-08-28

for you to fetch changes up to 5307eca1362492ce28f1572b430997d9053c021d:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-driver=
s.git (2017-08-24 14:47:42 +0300)

----------------------------------------------------------------
wireless-drivers-next patches for 4.14

rsi driver is getting a lot of new features lately, but as usual
active development happening on iwlwifi as well as other drivers.

I pulled wireless-drivers to fix multiple conflicts in iwlwifi and to
make it easier further development.

Major changes:

ath10k

* initial UBS bus support (no full support yet)

* add tdls support for 10.4 firmware

ath9k

* add Dell Wireless 1802

wil6210

* support FW RSSI reporting

rsi

* support legacy power save, U-APSD, rf-kill and AP mode

* RTS threshold configuration

brcmfmac

* support CYW4373 SDIO/USB chipset

iwlwifi

* some more code moved to a new directory

* add new PCI ID for 7265D

----------------------------------------------------------------
Arvind Yadav (19):
      ar5523: constify usb_device_id
      carl9170: constify usb_device_id
      at76c50x: constify usb_device_id
      orinoco: constify usb_device_id
      p54: constify usb_device_id
      libertas: constify usb_device_id
      libertas_tf: constify usb_device_id
      mwifiex: constify usb_device_id
      mt7601u: constify usb_device_id
      rt2500usb: constify usb_device_id
      rt2800usb: constify usb_device_id
      rt73usb: constify usb_device_id
      rtl8187: constify usb_device_id
      rtl8xxxu: constify usb_device_id
      rtl8192cu: constify usb_device_id
      zd1201: constify usb_device_id
      zd1211rw: constify usb_device_id
      brcm80211: constify usb_device_id
      net: rsi: mac80211: constify ieee80211_ops

Avraham Stern (1):
      iwlwifi: mvm: remove session protection to allow channel switch

Bhumika Goyal (4):
      wlcore: add const to bin_attribute structure
      rtlwifi: constify rate_control_ops structure
      iwlwifi: mvm: add const to thermal_cooling_device_ops structure
      wireless: ipw2x00: make iw_handler_def const

Chaya Rachel Ivgi (2):
      iwlwifi: mvm: add debugfs to force CT-kill
      iwlwifi: mvm: set the default cTDP budget

Chi-Hsien Lin (1):
      brcmfmac: Add support for CYW4373 SDIO/USB chipset

Christoph Fritz (1):
      ath9k: fix debugfs file permission

Christophe Jaillet (1):
      mt7601u: check memory allocation failure

Chung-Hsien Hsu (1):
      brcmfmac: add setting carrier state ON for successful roaming

Colin Ian King (1):
      rtlwifi: rtl8821ae: fix spelling mistake: "faill" -> "failed"

Dan Carpenter (1):
      rtlwifi: make a couple arrays larger

Emmanuel Grumbach (10):
      iwlwifi: pcie: don't init a Tx queue with an SSN > size of the queue
      iwlwifi: pcie: free the TSO page when a Tx queue is unmapped on A000 =
devices
      iwlwifi: mvm: fix the coex firmware API
      iwlwifi: mvm: remove the corunning support
      iwlwifi: mvm: support new Coex firmware API
      iwlwifi: pcie: support short Tx queues for A000 device family
      iwlwifi: mvm: add command name for FRAME_RELEASE
      iwlwifi: mvm: include more debug data when we get an unexpected baid
      iwlwifi: mvm: update the firmware API in TX
      iwlwifi: mvm: don't send BAR on flushed frames

Erik Stromdahl (3):
      ath10k: various usb related definitions
      ath10k: add initial USB support
      ath10k: sdio: fix compile warning

Ganapathi Bhat (3):
      mwifiex: replace netif_carrier_on/off by netif_device_attach/dettach
      mwifiex: do not use random MAC for pre-association scanning
      mwifiex: check for NL80211_SCAN_FLAG_RANDOM_ADDR during hidden SSID s=
can

Golan Ben-Ami (2):
      iwlwifi: dump smem configuration when firmware crashes
      iwlwifi: fix nmi triggering from host

Gregory Greenman (1):
      iwlwifi: mvm: change open and close criteria of a BA session

Gustavo A. R. Silva (1):
      rtlwifi: btcoex: 23b 1ant: fix duplicated code for different branches

Haim Dreyfuss (1):
      iwlwifi: mvm: support new beacon template command

Ilan Peer (1):
      iwlwifi: mvm: Fix channel switch in case of count <=3D 1

Johannes Berg (2):
      iwlwifi: mvm: remove useless condition in LED code
      iwlwifi: mvm: use firmware LED command where applicable

Jo=C3=A3o Paulo Rechi Vita (1):
      iwlwifi: Demote messages about fw flags size to info

Kalle Valo (4):
      Merge tag 'iwlwifi-next-for-kalle-2017-08-11' of git://git.kernel.org=
/.../iwlwifi/iwlwifi-next
      Merge tag 'iwlwifi-next-for-kalle-2017-08-18' of git://git.kernel.org=
/.../iwlwifi/iwlwifi-next
      Merge ath-next from git://git.kernel.org/.../kvalo/ath.git
      Merge git://git.kernel.org/.../kvalo/wireless-drivers.git

Karun Eagalapati (6):
      rsi: add support for legacy power save
      rsi: add support for U-APSD power save
      rsi: rename sdio_read_buffer_status_register
      rsi: buffer full check optimization
      rsi: buffer available interrupt handling
      rsi: RTS threshold configuration

Liad Kaufman (1):
      iwlwifi: fix a000 RF_ID define

Luca Coelho (14):
      iwlwifi: fix a few instances of misaligned kerneldoc parameters
      iwlwifi: remove references to unsupported HW
      iwlwifi: mvm: consider RFKILL during INIT as success
      iwlwifi: call iwl_remove_notification from iwl_wait_notification
      iwlwifi: mvm: group all dummy SAR function declarations together
      iwlwifi: mvm: use mvmsta consistently in rs.c
      iwlwifi: move BT_MBOX_PRINT macro to common header
      iwlwifi: pci: add new PCI ID for 7265D
      iwlwifi: update channel flags parser
      iwlwifi: add workaround to disable wide channels in 5GHz
      iwlwifi: fw: fix lar_enabled endian problem in iwl_fw_get_nvm
      iwlwifi: mvm: remove useless argument in iwl_nvm_init()
      iwlwifi: mvm: remove useless check for mvm->cfg in iwl_parse_nvm_sect=
ion()
      iwlwifi: use big-endian for the hw section of the nvm

Manikanta Pubbisetty (3):
      ath10k: extend wmi service map to accommodate new services
      ath10k: add tdls support for 10.4 firmwares
      ath10k: push peer type to target for TDLS peers

Matt Chen (1):
      iwlwifi: mvm: don't send CTDP commands via debugfs if not supported

Matthias Frei (1):
      ath10k: set a-mpdu receiver reference number

Michael Skeffington (1):
      rt2x00: Fix MMIC Countermeasures

Pavani Muthyala (2):
      rsi: add support for rf-kill functionality
      rsi: update set_antenna command frame

Philipp Zabel (1):
      ath10k: explicitly request exclusive reset control

Prameela Rani Garnepudi (12):
      rsi: fix uninitialized descriptor pointer issue
      rsi: advertise ap mode support
      rsi: add interface changes for ap mode
      rsi: remove interface changes for AP mode
      rsi: add beacon changes for AP mode
      rsi: handle station connection in AP mode
      rsi: handle station disconnection in AP mode
      rsi: data and managemet path changes for AP mode
      rsi: use common descriptor for auto rate frame
      rsi: update tx auto rate command frame for AP mode
      rsi: aggregation parameters frame for AP mode
      rsi: security enhancements for AP mode

Reizer, Eyal (1):
      wlcore: add missing nvs file name info for wilink8

Rob Clark (1):
      wcn36xx: check dma_mapping_error()

Romain Perier (1):
      wireless: ipw2200: Replace PCI pool old API

Rosen Penev (1):
      ath9k: Add Dell Wireless 1802 with wowlan capability

Sergey Matyukevich (8):
      qtnfmac: remove unused qtnf_rx_frame declaration
      qtnfmac: switch to napi_gro_receive
      qtnfmac: use __netdev_alloc_skb_ip_align
      qtnfmac: skb2rbd_attach cleanup
      qtnfmac: decrease default Tx queue size
      qtnfmac: switch to kernel circ_buf implementation
      qtnfmac: introduce counter for Rx underflow events
      qtnfmac: modify tx reclaim locking

Sharon Dvir (1):
      iwlwifi: change functions that can only return 0 to void

Shaul Triebitz (2):
      iwlwifi: mvm: move a000 device NVM retrieval to a common place
      iwlwifi: mvm: add station before allocating a queue

Tzipi Peres (2):
      iwlwifi: add support of FPGA fw
      iwlwifi: distinguish different RF modules in A000 devices

Vincent Legoll (1):
      bcma: make BCMA a menuconfig to ease disabling it all

Wright Feng (2):
      brcmfmac: set wpa_auth to WPA_AUTH_DISABLED in AP/OPEN security mode
      brcmfmac: fix wrong num_different_channels when mchan feature enabled

Xinming Hu (4):
      mwifiex: Do not change bss_num in change_virtual_intf
      mwifiex: wrapper wps ie in pass through tlv
      mwifiex: p2p: use separate device address
      mwifiex: uap: enable 11d based on userspace configruation

 drivers/bcma/Kconfig                                             |    9 +-
 drivers/net/wireless/ath/ar5523/ar5523.c                         |    2 +-
 drivers/net/wireless/ath/ath10k/Kconfig                          |    7 +
 drivers/net/wireless/ath/ath10k/Makefile                         |    3 +
 drivers/net/wireless/ath/ath10k/ahb.c                            |   15 +-
 drivers/net/wireless/ath/ath10k/core.c                           |   10 +
 drivers/net/wireless/ath/ath10k/core.h                           |    5 +
 drivers/net/wireless/ath/ath10k/debug.h                          |    2 +
 drivers/net/wireless/ath/ath10k/htt_rx.c                         |   12 +-
 drivers/net/wireless/ath/ath10k/hw.h                             |    5 +
 drivers/net/wireless/ath/ath10k/mac.c                            |    5 +-
 drivers/net/wireless/ath/ath10k/sdio.c                           |    8 +-
 drivers/net/wireless/ath/ath10k/usb.c                            | 1106 ++=
+++++++++++++++++++++++++++++
 drivers/net/wireless/ath/ath10k/usb.h                            |  128 ++=
++
 drivers/net/wireless/ath/ath10k/wmi.c                            |  164 ++=
++-
 drivers/net/wireless/ath/ath10k/wmi.h                            |  271 ++=
+++++-
 drivers/net/wireless/ath/ath9k/debug.c                           |    2 +-
 drivers/net/wireless/ath/ath9k/pci.c                             |    5 +
 drivers/net/wireless/ath/carl9170/usb.c                          |    2 +-
 drivers/net/wireless/ath/wcn36xx/dxe.c                           |    5 +
 drivers/net/wireless/atmel/at76c50x-usb.c                        |    2 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcmsdh.c        |    1 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c      |   18 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/chip.c          |    2 +
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c          |    4 +-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/usb.c           |   11 +-
 drivers/net/wireless/broadcom/brcm80211/include/brcm_hw_ids.h    |    3 +
 drivers/net/wireless/intel/ipw2x00/ipw2100.c                     |    4 +-
 drivers/net/wireless/intel/ipw2x00/ipw2200.c                     |   15 +-
drivers/net/wireless/intel/iwlwifi/Makefile                      |    2 +-
 drivers/net/wireless/intel/iwlwifi/cfg/a000.c                    |   42 ++
 drivers/net/wireless/intel/iwlwifi/dvm/commands.h                |    8 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/coex.h                 |   62 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/commands.h             |   17 +-
 drivers/net/wireless/intel/iwlwifi/fw/api/config.h               |    8 -
 drivers/net/wireless/intel/iwlwifi/fw/api/led.h                  |   71 ++
 drivers/net/wireless/intel/iwlwifi/fw/api/tx.h                   |   28 +-
 drivers/net/wireless/intel/iwlwifi/fw/dbg.c                      |   38 +-
 drivers/net/wireless/intel/iwlwifi/fw/error-dump.h               |   30 +
 drivers/net/wireless/intel/iwlwifi/fw/file.h                     |    4 +
 drivers/net/wireless/intel/iwlwifi/fw/notif-wait.c               |   25 +-
 drivers/net/wireless/intel/iwlwifi/fw/nvm.c                      |  162 ++=
+++
 drivers/net/wireless/intel/iwlwifi/fw/runtime.h                  |    2 +
 drivers/net/wireless/intel/iwlwifi/fw/smem.c                     |    3 +
 drivers/net/wireless/intel/iwlwifi/iwl-config.h                  |    3 +
 drivers/net/wireless/intel/iwlwifi/iwl-csr.h                     |   11 +-
 drivers/net/wireless/intel/iwlwifi/iwl-drv.c                     |   36 +-
 drivers/net/wireless/intel/iwlwifi/iwl-io.c                      |   14 +-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.c               |  116 ++=
+-
 drivers/net/wireless/intel/iwlwifi/iwl-nvm-parse.h               |    5 +-
 drivers/net/wireless/intel/iwlwifi/iwl-prph.h                    |   13 +-
 drivers/net/wireless/intel/iwlwifi/mvm/coex.c                    |  308 +-=
-------
 drivers/net/wireless/intel/iwlwifi/mvm/constants.h               |    2 +-
 drivers/net/wireless/intel/iwlwifi/mvm/debugfs.c                 |   54 +-
 drivers/net/wireless/intel/iwlwifi/mvm/fw-api.h                  |    1 +
 drivers/net/wireless/intel/iwlwifi/mvm/fw.c                      |   69 +-
 drivers/net/wireless/intel/iwlwifi/mvm/led.c                     |   59 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac-ctxt.c                |   47 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mac80211.c                |   16 +-
 drivers/net/wireless/intel/iwlwifi/mvm/mvm.h                     |   37 +-
 drivers/net/wireless/intel/iwlwifi/mvm/nvm.c                     |  197 ++=
----
 drivers/net/wireless/intel/iwlwifi/mvm/ops.c                     |    7 +-
 drivers/net/wireless/intel/iwlwifi/mvm/rs.c                      |  142 ++=
--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.c                     |  108 +--
 drivers/net/wireless/intel/iwlwifi/mvm/sta.h                     |    7 +
 drivers/net/wireless/intel/iwlwifi/mvm/time-event.c              |   34 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tt.c                      |    4 +-
 drivers/net/wireless/intel/iwlwifi/mvm/tx.c                      |    9 +-
 drivers/net/wireless/intel/iwlwifi/pcie/ctxt-info.c              |    2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/drv.c                    |   24 +-
 drivers/net/wireless/intel/iwlwifi/pcie/internal.h               |   15 +-
 drivers/net/wireless/intel/iwlwifi/pcie/rx.c                     |    2 +-
 drivers/net/wireless/intel/iwlwifi/pcie/trans.c                  |   22 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx-gen2.c                |   55 +-
 drivers/net/wireless/intel/iwlwifi/pcie/tx.c                     |   17 +-
 drivers/net/wireless/intersil/orinoco/orinoco_usb.c              |    2 +-
 drivers/net/wireless/intersil/p54/p54usb.c                       |    2 +-
 drivers/net/wireless/marvell/libertas/if_usb.c                   |    2 +-
 drivers/net/wireless/marvell/libertas_tf/if_usb.c                |    2 +-
 drivers/net/wireless/marvell/mwifiex/cfg80211.c                  |   29 +-
 drivers/net/wireless/marvell/mwifiex/join.c                      |    2 +-
 drivers/net/wireless/marvell/mwifiex/main.c                      |   40 +-
 drivers/net/wireless/marvell/mwifiex/main.h                      |    7 +
 drivers/net/wireless/marvell/mwifiex/scan.c                      |    4 +-
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c                   |   34 +-
 drivers/net/wireless/marvell/mwifiex/usb.c                       |    2 +-
 drivers/net/wireless/mediatek/mt7601u/dma.c                      |    5 +
 drivers/net/wireless/mediatek/mt7601u/usb.c                      |    2 +-
 drivers/net/wireless/quantenna/qtnfmac/bus.h                     |    1 -
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie.c              |  279 ++=
++----
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_bus_priv.h     |   15 +-
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_ipc.h          |    1 +
 drivers/net/wireless/quantenna/qtnfmac/pearl/pcie_regs_pearl.h   |    1 +
 drivers/net/wireless/ralink/rt2x00/rt2500usb.c                   |    2 +-
 drivers/net/wireless/ralink/rt2x00/rt2800mmio.c                  |   13 +-
 drivers/net/wireless/ralink/rt2x00/rt2800usb.c                   |   17 +-
 drivers/net/wireless/ralink/rt2x00/rt73usb.c                     |    2 +-
 drivers/net/wireless/realtek/rtl818x/rtl8187/dev.c               |    2 +-
 drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_core.c            |    2 +-
 drivers/net/wireless/realtek/rtlwifi/btcoexist/halbtc8723b1ant.c |   10 +-
 drivers/net/wireless/realtek/rtlwifi/rc.c                        |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c              |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/fw.c              |    2 +-
 drivers/net/wireless/realtek/rtlwifi/rtl8821ae/phy.c             |    5 +-
 drivers/net/wireless/rsi/Makefile                                |    1 +
 drivers/net/wireless/rsi/rsi_91x_core.c                          |   70 +-
 drivers/net/wireless/rsi/rsi_91x_hal.c                           |  136 ++=
+-
 drivers/net/wireless/rsi/rsi_91x_mac80211.c                      |  415 ++=
++++++++--
 drivers/net/wireless/rsi/rsi_91x_main.c                          |    2 +
 drivers/net/wireless/rsi/rsi_91x_mgmt.c                          |  285 ++=
++++--
 drivers/net/wireless/rsi/rsi_91x_ps.c                            |  146 ++=
++
 drivers/net/wireless/rsi/rsi_91x_sdio.c                          |    2 +-
 drivers/net/wireless/rsi/rsi_91x_sdio_ops.c                      |   40 +-
 drivers/net/wireless/rsi/rsi_common.h                            |    1 +
 drivers/net/wireless/rsi/rsi_hal.h                               |    4 +-
 drivers/net/wireless/rsi/rsi_main.h                              |   38 +-
 drivers/net/wireless/rsi/rsi_mgmt.h                              |   87 ++-
 drivers/net/wireless/rsi/rsi_ps.h                                |   64 ++
 drivers/net/wireless/rsi/rsi_sdio.h                              |    3 +-
 drivers/net/wireless/ti/wlcore/main.c                            |   23 +
 drivers/net/wireless/ti/wlcore/sdio.c                            |    1 +
 drivers/net/wireless/ti/wlcore/spi.c                             |    1 +
 drivers/net/wireless/ti/wlcore/sysfs.c                           |    2 +-
 drivers/net/wireless/ti/wlcore/wlcore.h                          |    3 +
 drivers/net/wireless/zydas/zd1201.c                              |    2 +-
 drivers/net/wireless/zydas/zd1211rw/zd_usb.c                     |    2 +-
 include/linux/mmc/sdio_ids.h                                     |    1 +
 127 files changed, 4310 insertions(+), 1272 deletions(-)
 create mode 100644 drivers/net/wireless/ath/ath10k/usb.c
 create mode 100644 drivers/net/wireless/ath/ath10k/usb.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/api/led.h
 create mode 100644 drivers/net/wireless/intel/iwlwifi/fw/nvm.c
 create mode 100644 drivers/net/wireless/rsi/rsi_91x_ps.c
 create mode 100644 drivers/net/wireless/rsi/rsi_ps.h
