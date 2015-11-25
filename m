From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: pull-request: wireless-drivers-next 2015-11-25
Date: Wed, 25 Nov 2015 10:59:43 +0200
Message-ID: <87mvu2pi80.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave,

here's first wireless-drivers pull request for 4.5. I'll start the cycle
with a big one as I'm adding vendor directories to wireless drivers.
This patch has been on linux-next since Monday and I haven't seen any
reports of breakage so I think this is now ready for you to pull. To
keep things simple I didn't add any other patches, if everything goes ok
I'm planning to send another pull request quite soon after this one.

Please let me know if you have any issues with this.

Kalle

The following changes since commit c5a37883f42be712a989e54d5d6c0159b0e56599:

  Merge branch 'akpm' (patches from Andrew) (2015-11-10 21:14:23 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/wireless-drivers-next.git tags/wireless-drivers-next-for-davem-2015-11-25

for you to fetch changes up to 6d808eba602b00f77f26191f45328774ff057cc0:

  mac80211_hwsim: move Kconfig entry for sorting alphabetically (2015-11-18 15:23:36 +0200)

----------------------------------------------------------------
Add vendor directories (for example intel, marvell and so on) to
drivers/net/wireless and change the menuconfig to follow the same
categorisation. This unifies the directory layout as we already had few drivers
already using vendor directories (especially ath and ti).

----------------------------------------------------------------
Kalle Valo (27):
      adm80211: move under admtek vendor directory
      airo: move under cisco vendor directory
      atmel: move under atmel vendor directory
      b43: move under broadcom vendor directory
      b43legacy: move under broadcom vendor directory
      brcm80211: move under broadcom vendor directory
      cw1200: move under st vendor directory
      ipw2x00: move under intel vendor directory
      iwlegacy: move under intel directory
      iwlwifi: move under intel vendor directory
      libertas: move under marvell vendor directory
      libertas_tf: move under marvell vendor directory
      mwifiex: move under marvell vendor directory
      mwl8k: move under marvell vendor directory
      zd1201: move under zydas vendor directory
      zd1211rw: move under zydas vendor directory
      hostap: move under intersil vendor directory
      p54: move under intersil vendor directory
      orinoco: move under intersil vendor directory
      prism54: move under intersil vendor directory
      realtek: create separate Kconfig file
      rsi: add vendor Kconfig entry
      rt2x00: move under ralink vendor directory
      mediatek: unify Kconfig with other vendors
      ti: unify Kconfig with other vendors
      ath: unify Kconfig with other vendors
      mac80211_hwsim: move Kconfig entry for sorting alphabetically

 MAINTAINERS                                        |   46 ++--
 drivers/net/wireless/Kconfig                       |  238 +++-----------------
 drivers/net/wireless/Makefile                      |   65 ++----
 drivers/net/wireless/admtek/Kconfig                |   41 ++++
 drivers/net/wireless/admtek/Makefile               |    1 +
 drivers/net/wireless/{ => admtek}/adm8211.c        |    0
 drivers/net/wireless/{ => admtek}/adm8211.h        |    0
 drivers/net/wireless/ath/Kconfig                   |   17 +-
 drivers/net/wireless/atmel/Kconfig                 |   57 +++++
 drivers/net/wireless/atmel/Makefile                |    5 +
 drivers/net/wireless/{ => atmel}/at76c50x-usb.c    |    0
 drivers/net/wireless/{ => atmel}/at76c50x-usb.h    |    0
 drivers/net/wireless/{ => atmel}/atmel.c           |    0
 drivers/net/wireless/{ => atmel}/atmel.h           |    0
 drivers/net/wireless/{ => atmel}/atmel_cs.c        |    0
 drivers/net/wireless/{ => atmel}/atmel_pci.c       |    0
 drivers/net/wireless/broadcom/Kconfig              |   18 ++
 drivers/net/wireless/broadcom/Makefile             |    5 +
 drivers/net/wireless/{ => broadcom}/b43/Kconfig    |    0
 drivers/net/wireless/{ => broadcom}/b43/Makefile   |    0
 drivers/net/wireless/{ => broadcom}/b43/b43.h      |    0
 drivers/net/wireless/{ => broadcom}/b43/bus.c      |    0
 drivers/net/wireless/{ => broadcom}/b43/bus.h      |    0
 drivers/net/wireless/{ => broadcom}/b43/debugfs.c  |    0
 drivers/net/wireless/{ => broadcom}/b43/debugfs.h  |    0
 drivers/net/wireless/{ => broadcom}/b43/dma.c      |    0
 drivers/net/wireless/{ => broadcom}/b43/dma.h      |    0
 drivers/net/wireless/{ => broadcom}/b43/leds.c     |    0
 drivers/net/wireless/{ => broadcom}/b43/leds.h     |    0
 drivers/net/wireless/{ => broadcom}/b43/lo.c       |    0
 drivers/net/wireless/{ => broadcom}/b43/lo.h       |    0
 drivers/net/wireless/{ => broadcom}/b43/main.c     |    0
 drivers/net/wireless/{ => broadcom}/b43/main.h     |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_a.c    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_a.h    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_ac.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_ac.h   |    0
 .../net/wireless/{ => broadcom}/b43/phy_common.c   |    0
 .../net/wireless/{ => broadcom}/b43/phy_common.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_g.c    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_g.h    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_ht.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_ht.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_lcn.c  |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_lcn.h  |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_lp.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_lp.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_n.c    |    0
 drivers/net/wireless/{ => broadcom}/b43/phy_n.h    |    0
 drivers/net/wireless/{ => broadcom}/b43/pio.c      |    0
 drivers/net/wireless/{ => broadcom}/b43/pio.h      |    0
 drivers/net/wireless/{ => broadcom}/b43/ppr.c      |    0
 drivers/net/wireless/{ => broadcom}/b43/ppr.h      |    0
 .../net/wireless/{ => broadcom}/b43/radio_2055.c   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2055.h   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2056.c   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2056.h   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2057.c   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2057.h   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2059.c   |    0
 .../net/wireless/{ => broadcom}/b43/radio_2059.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/rfkill.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/rfkill.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/sdio.c     |    0
 drivers/net/wireless/{ => broadcom}/b43/sdio.h     |    0
 drivers/net/wireless/{ => broadcom}/b43/sysfs.c    |    0
 drivers/net/wireless/{ => broadcom}/b43/sysfs.h    |    0
 drivers/net/wireless/{ => broadcom}/b43/tables.c   |    0
 drivers/net/wireless/{ => broadcom}/b43/tables.h   |    0
 .../net/wireless/{ => broadcom}/b43/tables_lpphy.c |    0
 .../net/wireless/{ => broadcom}/b43/tables_lpphy.h |    0
 .../net/wireless/{ => broadcom}/b43/tables_nphy.c  |    0
 .../net/wireless/{ => broadcom}/b43/tables_nphy.h  |    0
 .../wireless/{ => broadcom}/b43/tables_phy_ht.c    |    0
 .../wireless/{ => broadcom}/b43/tables_phy_ht.h    |    0
 .../wireless/{ => broadcom}/b43/tables_phy_lcn.c   |    0
 .../wireless/{ => broadcom}/b43/tables_phy_lcn.h   |    0
 drivers/net/wireless/{ => broadcom}/b43/wa.c       |    0
 drivers/net/wireless/{ => broadcom}/b43/wa.h       |    0
 drivers/net/wireless/{ => broadcom}/b43/xmit.c     |    0
 drivers/net/wireless/{ => broadcom}/b43/xmit.h     |    0
 .../net/wireless/{ => broadcom}/b43legacy/Kconfig  |    0
 .../net/wireless/{ => broadcom}/b43legacy/Makefile |    0
 .../wireless/{ => broadcom}/b43legacy/b43legacy.h  |    0
 .../wireless/{ => broadcom}/b43legacy/debugfs.c    |    0
 .../wireless/{ => broadcom}/b43legacy/debugfs.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/dma.c    |    0
 .../net/wireless/{ => broadcom}/b43legacy/dma.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/ilt.c    |    0
 .../net/wireless/{ => broadcom}/b43legacy/ilt.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/leds.c   |    0
 .../net/wireless/{ => broadcom}/b43legacy/leds.h   |    0
 .../net/wireless/{ => broadcom}/b43legacy/main.c   |    0
 .../net/wireless/{ => broadcom}/b43legacy/main.h   |    0
 .../net/wireless/{ => broadcom}/b43legacy/phy.c    |    0
 .../net/wireless/{ => broadcom}/b43legacy/phy.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/pio.c    |    0
 .../net/wireless/{ => broadcom}/b43legacy/pio.h    |    0
 .../net/wireless/{ => broadcom}/b43legacy/radio.c  |    0
 .../net/wireless/{ => broadcom}/b43legacy/radio.h  |    0
 .../net/wireless/{ => broadcom}/b43legacy/rfkill.c |    0
 .../net/wireless/{ => broadcom}/b43legacy/rfkill.h |    0
 .../net/wireless/{ => broadcom}/b43legacy/sysfs.c  |    0
 .../net/wireless/{ => broadcom}/b43legacy/sysfs.h  |    0
 .../net/wireless/{ => broadcom}/b43legacy/xmit.c   |    0
 .../net/wireless/{ => broadcom}/b43legacy/xmit.h   |    0
 .../net/wireless/{ => broadcom}/brcm80211/Kconfig  |    0
 .../net/wireless/{ => broadcom}/brcm80211/Makefile |    0
 .../{ => broadcom}/brcm80211/brcmfmac/Makefile     |    4 +-
 .../{ => broadcom}/brcm80211/brcmfmac/bcdc.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/bcdc.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/bcmsdh.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/btcoex.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/btcoex.h     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/bus.h        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/cfg80211.c   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/cfg80211.h   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/chip.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/chip.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/common.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/common.h     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/commonring.c |    0
 .../{ => broadcom}/brcm80211/brcmfmac/commonring.h |    0
 .../{ => broadcom}/brcm80211/brcmfmac/core.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/core.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/debug.c      |    0
 .../{ => broadcom}/brcm80211/brcmfmac/debug.h      |    0
 .../{ => broadcom}/brcm80211/brcmfmac/feature.c    |    0
 .../{ => broadcom}/brcm80211/brcmfmac/feature.h    |    0
 .../{ => broadcom}/brcm80211/brcmfmac/firmware.c   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/firmware.h   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/flowring.c   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/flowring.h   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fweh.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fweh.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwil.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwil.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwil_types.h |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwsignal.c   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/fwsignal.h   |    0
 .../{ => broadcom}/brcm80211/brcmfmac/msgbuf.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/msgbuf.h     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/of.c         |    0
 .../{ => broadcom}/brcm80211/brcmfmac/of.h         |    0
 .../{ => broadcom}/brcm80211/brcmfmac/p2p.c        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/p2p.h        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/pcie.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/pcie.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/proto.c      |    0
 .../{ => broadcom}/brcm80211/brcmfmac/proto.h      |    0
 .../{ => broadcom}/brcm80211/brcmfmac/sdio.c       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/sdio.h       |    0
 .../{ => broadcom}/brcm80211/brcmfmac/tracepoint.c |    0
 .../{ => broadcom}/brcm80211/brcmfmac/tracepoint.h |    0
 .../{ => broadcom}/brcm80211/brcmfmac/usb.c        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/usb.h        |    0
 .../{ => broadcom}/brcm80211/brcmfmac/vendor.c     |    0
 .../{ => broadcom}/brcm80211/brcmfmac/vendor.h     |    0
 .../{ => broadcom}/brcm80211/brcmsmac/Makefile     |    6 +-
 .../{ => broadcom}/brcm80211/brcmsmac/aiutils.c    |    0
 .../{ => broadcom}/brcm80211/brcmsmac/aiutils.h    |    0
 .../{ => broadcom}/brcm80211/brcmsmac/ampdu.c      |    0
 .../{ => broadcom}/brcm80211/brcmsmac/ampdu.h      |    0
 .../{ => broadcom}/brcm80211/brcmsmac/antsel.c     |    0
 .../{ => broadcom}/brcm80211/brcmsmac/antsel.h     |    0
 .../brcm80211/brcmsmac/brcms_trace_brcmsmac.h      |    0
 .../brcm80211/brcmsmac/brcms_trace_brcmsmac_msg.h  |    0
 .../brcm80211/brcmsmac/brcms_trace_brcmsmac_tx.h   |    0
 .../brcm80211/brcmsmac/brcms_trace_events.c        |    0
 .../brcm80211/brcmsmac/brcms_trace_events.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/channel.c    |    0
 .../{ => broadcom}/brcm80211/brcmsmac/channel.h    |    0
 .../{ => broadcom}/brcm80211/brcmsmac/d11.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/debug.c      |    0
 .../{ => broadcom}/brcm80211/brcmsmac/debug.h      |    0
 .../{ => broadcom}/brcm80211/brcmsmac/dma.c        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/dma.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/led.c        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/led.h        |    0
 .../brcm80211/brcmsmac/mac80211_if.c               |    0
 .../brcm80211/brcmsmac/mac80211_if.h               |    0
 .../{ => broadcom}/brcm80211/brcmsmac/main.c       |    0
 .../{ => broadcom}/brcm80211/brcmsmac/main.h       |    0
 .../brcm80211/brcmsmac/phy/phy_cmn.c               |    0
 .../brcm80211/brcmsmac/phy/phy_hal.h               |    0
 .../brcm80211/brcmsmac/phy/phy_int.h               |    0
 .../brcm80211/brcmsmac/phy/phy_lcn.c               |    0
 .../brcm80211/brcmsmac/phy/phy_lcn.h               |    0
 .../{ => broadcom}/brcm80211/brcmsmac/phy/phy_n.c  |    0
 .../brcm80211/brcmsmac/phy/phy_qmath.c             |    0
 .../brcm80211/brcmsmac/phy/phy_qmath.h             |    0
 .../brcm80211/brcmsmac/phy/phy_radio.h             |    0
 .../brcm80211/brcmsmac/phy/phyreg_n.h              |    0
 .../brcm80211/brcmsmac/phy/phytbl_lcn.c            |    0
 .../brcm80211/brcmsmac/phy/phytbl_lcn.h            |    0
 .../brcm80211/brcmsmac/phy/phytbl_n.c              |    0
 .../brcm80211/brcmsmac/phy/phytbl_n.h              |    0
 .../{ => broadcom}/brcm80211/brcmsmac/phy_shim.c   |    0
 .../{ => broadcom}/brcm80211/brcmsmac/phy_shim.h   |    0
 .../{ => broadcom}/brcm80211/brcmsmac/pmu.c        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/pmu.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/pub.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/rate.c       |    0
 .../{ => broadcom}/brcm80211/brcmsmac/rate.h       |    0
 .../{ => broadcom}/brcm80211/brcmsmac/scb.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/stf.c        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/stf.h        |    0
 .../{ => broadcom}/brcm80211/brcmsmac/types.h      |    0
 .../brcm80211/brcmsmac/ucode_loader.c              |    0
 .../brcm80211/brcmsmac/ucode_loader.h              |    0
 .../{ => broadcom}/brcm80211/brcmutil/Makefile     |    4 +-
 .../{ => broadcom}/brcm80211/brcmutil/d11.c        |    0
 .../{ => broadcom}/brcm80211/brcmutil/utils.c      |    0
 .../{ => broadcom}/brcm80211/include/brcm_hw_ids.h |    0
 .../{ => broadcom}/brcm80211/include/brcmu_d11.h   |    0
 .../{ => broadcom}/brcm80211/include/brcmu_utils.h |    0
 .../{ => broadcom}/brcm80211/include/brcmu_wifi.h  |    0
 .../{ => broadcom}/brcm80211/include/chipcommon.h  |    0
 .../{ => broadcom}/brcm80211/include/defs.h        |    0
 .../{ => broadcom}/brcm80211/include/soc.h         |    0
 drivers/net/wireless/cisco/Kconfig                 |   56 +++++
 drivers/net/wireless/cisco/Makefile                |    2 +
 drivers/net/wireless/{ => cisco}/airo.c            |    0
 drivers/net/wireless/{ => cisco}/airo.h            |    0
 drivers/net/wireless/{ => cisco}/airo_cs.c         |    0
 drivers/net/wireless/intel/Kconfig                 |   18 ++
 drivers/net/wireless/intel/Makefile                |    6 +
 drivers/net/wireless/{ => intel}/ipw2x00/Kconfig   |    0
 drivers/net/wireless/{ => intel}/ipw2x00/Makefile  |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw.h     |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw2100.c |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw2100.h |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw2200.c |    0
 drivers/net/wireless/{ => intel}/ipw2x00/ipw2200.h |    0
 drivers/net/wireless/{ => intel}/ipw2x00/libipw.h  |    0
 .../net/wireless/{ => intel}/ipw2x00/libipw_geo.c  |    0
 .../wireless/{ => intel}/ipw2x00/libipw_module.c   |    0
 .../net/wireless/{ => intel}/ipw2x00/libipw_rx.c   |    0
 .../net/wireless/{ => intel}/ipw2x00/libipw_tx.c   |    0
 .../net/wireless/{ => intel}/ipw2x00/libipw_wx.c   |    0
 .../net/wireless/{ => intel}/iwlegacy/3945-debug.c |    0
 .../net/wireless/{ => intel}/iwlegacy/3945-mac.c   |    0
 .../net/wireless/{ => intel}/iwlegacy/3945-rs.c    |    0
 drivers/net/wireless/{ => intel}/iwlegacy/3945.c   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/3945.h   |    0
 .../net/wireless/{ => intel}/iwlegacy/4965-calib.c |    0
 .../net/wireless/{ => intel}/iwlegacy/4965-debug.c |    0
 .../net/wireless/{ => intel}/iwlegacy/4965-mac.c   |    0
 .../net/wireless/{ => intel}/iwlegacy/4965-rs.c    |    0
 drivers/net/wireless/{ => intel}/iwlegacy/4965.c   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/4965.h   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/Kconfig  |    0
 drivers/net/wireless/{ => intel}/iwlegacy/Makefile |    0
 .../net/wireless/{ => intel}/iwlegacy/commands.h   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/common.c |    0
 drivers/net/wireless/{ => intel}/iwlegacy/common.h |    0
 drivers/net/wireless/{ => intel}/iwlegacy/csr.h    |    0
 drivers/net/wireless/{ => intel}/iwlegacy/debug.c  |    0
 .../wireless/{ => intel}/iwlegacy/iwl-spectrum.h   |    0
 drivers/net/wireless/{ => intel}/iwlegacy/prph.h   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/Kconfig   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/Makefile  |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/Makefile  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/agn.h |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/calib.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/calib.h   |    0
 .../wireless/{ => intel}/iwlwifi/dvm/commands.h    |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/debugfs.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/dev.h |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/devices.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/led.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/led.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/lib.c |    0
 .../wireless/{ => intel}/iwlwifi/dvm/mac80211.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/main.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/power.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/power.h   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/rs.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/rs.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/rx.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/rxon.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/scan.c    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/sta.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/tt.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/tt.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/dvm/tx.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/dvm/ucode.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-1000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-2000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-5000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-6000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-7000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-8000.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-agn-hw.h  |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-config.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-csr.h |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-debug.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-debug.h   |    0
 .../{ => intel}/iwlwifi/iwl-devtrace-data.h        |    0
 .../wireless/{ => intel}/iwlwifi/iwl-devtrace-io.h |    0
 .../{ => intel}/iwlwifi/iwl-devtrace-iwlwifi.h     |    0
 .../{ => intel}/iwlwifi/iwl-devtrace-msg.h         |    0
 .../{ => intel}/iwlwifi/iwl-devtrace-ucode.h       |    0
 .../wireless/{ => intel}/iwlwifi/iwl-devtrace.c    |    0
 .../wireless/{ => intel}/iwlwifi/iwl-devtrace.h    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-drv.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-drv.h |    0
 .../{ => intel}/iwlwifi/iwl-eeprom-parse.c         |    0
 .../{ => intel}/iwlwifi/iwl-eeprom-parse.h         |    0
 .../wireless/{ => intel}/iwlwifi/iwl-eeprom-read.c |    0
 .../wireless/{ => intel}/iwlwifi/iwl-eeprom-read.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-fh.h  |    0
 .../{ => intel}/iwlwifi/iwl-fw-error-dump.h        |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-fw-file.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-fw.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-io.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-io.h  |    0
 .../wireless/{ => intel}/iwlwifi/iwl-modparams.h   |    0
 .../wireless/{ => intel}/iwlwifi/iwl-notif-wait.c  |    0
 .../wireless/{ => intel}/iwlwifi/iwl-notif-wait.h  |    0
 .../wireless/{ => intel}/iwlwifi/iwl-nvm-parse.c   |    0
 .../wireless/{ => intel}/iwlwifi/iwl-nvm-parse.h   |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-op-mode.h |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-phy-db.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-phy-db.h  |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-prph.h    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/iwl-scd.h |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-trans.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/iwl-trans.h   |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/Makefile  |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/binding.c |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/coex.c    |    0
 .../wireless/{ => intel}/iwlwifi/mvm/coex_legacy.c |    0
 .../wireless/{ => intel}/iwlwifi/mvm/constants.h   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/d3.c  |    0
 .../wireless/{ => intel}/iwlwifi/mvm/debugfs-vif.c |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/debugfs.c |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/debugfs.h |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-coex.h |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-d3.h   |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-mac.h  |    0
 .../{ => intel}/iwlwifi/mvm/fw-api-power.h         |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-rs.h   |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-rx.h   |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-scan.h |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-sta.h  |    0
 .../{ => intel}/iwlwifi/mvm/fw-api-stats.h         |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-tof.h  |    0
 .../wireless/{ => intel}/iwlwifi/mvm/fw-api-tx.h   |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/fw-api.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/led.c |    0
 .../wireless/{ => intel}/iwlwifi/mvm/mac-ctxt.c    |    0
 .../wireless/{ => intel}/iwlwifi/mvm/mac80211.c    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/mvm.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/nvm.c |    0
 .../wireless/{ => intel}/iwlwifi/mvm/offloading.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/ops.c |    0
 .../wireless/{ => intel}/iwlwifi/mvm/phy-ctxt.c    |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/power.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/quota.c   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/rs.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/rs.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/rx.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/scan.c    |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/sf.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/sta.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/sta.h |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/tdls.c    |    0
 .../wireless/{ => intel}/iwlwifi/mvm/testmode.h    |    0
 .../wireless/{ => intel}/iwlwifi/mvm/time-event.c  |    0
 .../wireless/{ => intel}/iwlwifi/mvm/time-event.h  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/tof.c |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/tof.h |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/tt.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/mvm/tx.c  |    0
 .../net/wireless/{ => intel}/iwlwifi/mvm/utils.c   |    0
 .../net/wireless/{ => intel}/iwlwifi/pcie/drv.c    |    0
 .../wireless/{ => intel}/iwlwifi/pcie/internal.h   |    0
 drivers/net/wireless/{ => intel}/iwlwifi/pcie/rx.c |    0
 .../net/wireless/{ => intel}/iwlwifi/pcie/trans.c  |    0
 drivers/net/wireless/{ => intel}/iwlwifi/pcie/tx.c |    0
 drivers/net/wireless/intersil/Kconfig              |   38 ++++
 drivers/net/wireless/intersil/Makefile             |    4 +
 drivers/net/wireless/{ => intersil}/hostap/Kconfig |    0
 .../net/wireless/{ => intersil}/hostap/Makefile    |    0
 .../net/wireless/{ => intersil}/hostap/hostap.h    |    0
 .../wireless/{ => intersil}/hostap/hostap_80211.h  |    0
 .../{ => intersil}/hostap/hostap_80211_rx.c        |    0
 .../{ => intersil}/hostap/hostap_80211_tx.c        |    0
 .../net/wireless/{ => intersil}/hostap/hostap_ap.c |    0
 .../net/wireless/{ => intersil}/hostap/hostap_ap.h |    0
 .../wireless/{ => intersil}/hostap/hostap_common.h |    0
 .../wireless/{ => intersil}/hostap/hostap_config.h |    0
 .../net/wireless/{ => intersil}/hostap/hostap_cs.c |    0
 .../{ => intersil}/hostap/hostap_download.c        |    0
 .../net/wireless/{ => intersil}/hostap/hostap_hw.c |    0
 .../wireless/{ => intersil}/hostap/hostap_info.c   |    0
 .../wireless/{ => intersil}/hostap/hostap_ioctl.c  |    0
 .../wireless/{ => intersil}/hostap/hostap_main.c   |    0
 .../wireless/{ => intersil}/hostap/hostap_pci.c    |    0
 .../wireless/{ => intersil}/hostap/hostap_plx.c    |    0
 .../wireless/{ => intersil}/hostap/hostap_proc.c   |    0
 .../wireless/{ => intersil}/hostap/hostap_wlan.h   |    0
 .../net/wireless/{ => intersil}/orinoco/Kconfig    |    0
 .../net/wireless/{ => intersil}/orinoco/Makefile   |    0
 .../net/wireless/{ => intersil}/orinoco/airport.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/cfg.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/cfg.h  |    0
 drivers/net/wireless/{ => intersil}/orinoco/fw.c   |    0
 drivers/net/wireless/{ => intersil}/orinoco/fw.h   |    0
 .../net/wireless/{ => intersil}/orinoco/hermes.c   |    0
 .../net/wireless/{ => intersil}/orinoco/hermes.h   |    0
 .../wireless/{ => intersil}/orinoco/hermes_dld.c   |    0
 .../wireless/{ => intersil}/orinoco/hermes_dld.h   |    0
 .../wireless/{ => intersil}/orinoco/hermes_rid.h   |    0
 drivers/net/wireless/{ => intersil}/orinoco/hw.c   |    0
 drivers/net/wireless/{ => intersil}/orinoco/hw.h   |    0
 drivers/net/wireless/{ => intersil}/orinoco/main.c |    0
 drivers/net/wireless/{ => intersil}/orinoco/main.h |    0
 drivers/net/wireless/{ => intersil}/orinoco/mic.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/mic.h  |    0
 .../net/wireless/{ => intersil}/orinoco/orinoco.h  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_cs.c   |    0
 .../{ => intersil}/orinoco/orinoco_nortel.c        |    0
 .../wireless/{ => intersil}/orinoco/orinoco_pci.c  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_pci.h  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_plx.c  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_tmd.c  |    0
 .../wireless/{ => intersil}/orinoco/orinoco_usb.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/scan.c |    0
 drivers/net/wireless/{ => intersil}/orinoco/scan.h |    0
 .../wireless/{ => intersil}/orinoco/spectrum_cs.c  |    0
 drivers/net/wireless/{ => intersil}/orinoco/wext.c |    0
 drivers/net/wireless/{ => intersil}/orinoco/wext.h |    0
 drivers/net/wireless/{ => intersil}/p54/Kconfig    |    0
 drivers/net/wireless/{ => intersil}/p54/Makefile   |    0
 drivers/net/wireless/{ => intersil}/p54/eeprom.c   |    0
 drivers/net/wireless/{ => intersil}/p54/eeprom.h   |    0
 drivers/net/wireless/{ => intersil}/p54/fwio.c     |    0
 drivers/net/wireless/{ => intersil}/p54/led.c      |    0
 drivers/net/wireless/{ => intersil}/p54/lmac.h     |    0
 drivers/net/wireless/{ => intersil}/p54/main.c     |    0
 drivers/net/wireless/{ => intersil}/p54/p54.h      |    0
 drivers/net/wireless/{ => intersil}/p54/p54pci.c   |    0
 drivers/net/wireless/{ => intersil}/p54/p54pci.h   |    0
 drivers/net/wireless/{ => intersil}/p54/p54spi.c   |    0
 drivers/net/wireless/{ => intersil}/p54/p54spi.h   |    0
 .../wireless/{ => intersil}/p54/p54spi_eeprom.h    |    0
 drivers/net/wireless/{ => intersil}/p54/p54usb.c   |    0
 drivers/net/wireless/{ => intersil}/p54/p54usb.h   |    0
 drivers/net/wireless/{ => intersil}/p54/txrx.c     |    0
 .../net/wireless/{ => intersil}/prism54/Makefile   |    0
 .../net/wireless/{ => intersil}/prism54/isl_38xx.c |    0
 .../net/wireless/{ => intersil}/prism54/isl_38xx.h |    0
 .../wireless/{ => intersil}/prism54/isl_ioctl.c    |    0
 .../wireless/{ => intersil}/prism54/isl_ioctl.h    |    0
 .../net/wireless/{ => intersil}/prism54/isl_oid.h  |    0
 .../wireless/{ => intersil}/prism54/islpci_dev.c   |    0
 .../wireless/{ => intersil}/prism54/islpci_dev.h   |    0
 .../wireless/{ => intersil}/prism54/islpci_eth.c   |    0
 .../wireless/{ => intersil}/prism54/islpci_eth.h   |    0
 .../{ => intersil}/prism54/islpci_hotplug.c        |    0
 .../wireless/{ => intersil}/prism54/islpci_mgt.c   |    0
 .../wireless/{ => intersil}/prism54/islpci_mgt.h   |    0
 .../net/wireless/{ => intersil}/prism54/oid_mgt.c  |    0
 .../net/wireless/{ => intersil}/prism54/oid_mgt.h  |    0
 .../wireless/{ => intersil}/prism54/prismcompat.h  |    0
 drivers/net/wireless/marvell/Kconfig               |   27 +++
 drivers/net/wireless/marvell/Makefile              |    6 +
 .../net/wireless/{ => marvell}/libertas/Kconfig    |    0
 .../net/wireless/{ => marvell}/libertas/LICENSE    |    0
 .../net/wireless/{ => marvell}/libertas/Makefile   |    0
 drivers/net/wireless/{ => marvell}/libertas/README |    0
 drivers/net/wireless/{ => marvell}/libertas/cfg.c  |    0
 drivers/net/wireless/{ => marvell}/libertas/cfg.h  |    0
 drivers/net/wireless/{ => marvell}/libertas/cmd.c  |    0
 drivers/net/wireless/{ => marvell}/libertas/cmd.h  |    0
 .../net/wireless/{ => marvell}/libertas/cmdresp.c  |    0
 .../net/wireless/{ => marvell}/libertas/debugfs.c  |    0
 .../net/wireless/{ => marvell}/libertas/debugfs.h  |    0
 drivers/net/wireless/{ => marvell}/libertas/decl.h |    0
 drivers/net/wireless/{ => marvell}/libertas/defs.h |    0
 drivers/net/wireless/{ => marvell}/libertas/dev.h  |    0
 .../net/wireless/{ => marvell}/libertas/ethtool.c  |    0
 .../net/wireless/{ => marvell}/libertas/firmware.c |    0
 drivers/net/wireless/{ => marvell}/libertas/host.h |    0
 .../net/wireless/{ => marvell}/libertas/if_cs.c    |    0
 .../net/wireless/{ => marvell}/libertas/if_sdio.c  |    0
 .../net/wireless/{ => marvell}/libertas/if_sdio.h  |    0
 .../net/wireless/{ => marvell}/libertas/if_spi.c   |    0
 .../net/wireless/{ => marvell}/libertas/if_spi.h   |    0
 .../net/wireless/{ => marvell}/libertas/if_usb.c   |    0
 .../net/wireless/{ => marvell}/libertas/if_usb.h   |    0
 drivers/net/wireless/{ => marvell}/libertas/main.c |    0
 drivers/net/wireless/{ => marvell}/libertas/mesh.c |    0
 drivers/net/wireless/{ => marvell}/libertas/mesh.h |    0
 .../net/wireless/{ => marvell}/libertas/radiotap.h |    0
 drivers/net/wireless/{ => marvell}/libertas/rx.c   |    0
 drivers/net/wireless/{ => marvell}/libertas/tx.c   |    0
 .../net/wireless/{ => marvell}/libertas/types.h    |    0
 drivers/net/wireless/marvell/libertas_tf/Kconfig   |   18 ++
 .../wireless/{ => marvell}/libertas_tf/Makefile    |    0
 .../net/wireless/{ => marvell}/libertas_tf/cmd.c   |    0
 .../wireless/{ => marvell}/libertas_tf/deb_defs.h  |    0
 .../wireless/{ => marvell}/libertas_tf/if_usb.c    |    0
 .../wireless/{ => marvell}/libertas_tf/if_usb.h    |    0
 .../{ => marvell}/libertas_tf/libertas_tf.h        |    0
 .../net/wireless/{ => marvell}/libertas_tf/main.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11ac.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11ac.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11h.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11n.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/11n.h   |    0
 .../net/wireless/{ => marvell}/mwifiex/11n_aggr.c  |    0
 .../net/wireless/{ => marvell}/mwifiex/11n_aggr.h  |    0
 .../wireless/{ => marvell}/mwifiex/11n_rxreorder.c |    0
 .../wireless/{ => marvell}/mwifiex/11n_rxreorder.h |    0
 drivers/net/wireless/{ => marvell}/mwifiex/Kconfig |    0
 .../net/wireless/{ => marvell}/mwifiex/Makefile    |    0
 drivers/net/wireless/{ => marvell}/mwifiex/README  |    0
 .../net/wireless/{ => marvell}/mwifiex/cfg80211.c  |    0
 .../net/wireless/{ => marvell}/mwifiex/cfg80211.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/cfp.c   |    0
 .../net/wireless/{ => marvell}/mwifiex/cmdevt.c    |    0
 .../net/wireless/{ => marvell}/mwifiex/debugfs.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/decl.h  |    0
 .../net/wireless/{ => marvell}/mwifiex/ethtool.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/fw.h    |    0
 drivers/net/wireless/{ => marvell}/mwifiex/ie.c    |    0
 drivers/net/wireless/{ => marvell}/mwifiex/init.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/ioctl.h |    0
 drivers/net/wireless/{ => marvell}/mwifiex/join.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/main.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/main.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/pcie.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/pcie.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/scan.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/sdio.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/sdio.h  |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_cmd.c   |    0
 .../wireless/{ => marvell}/mwifiex/sta_cmdresp.c   |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_event.c |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_ioctl.c |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_rx.c    |    0
 .../net/wireless/{ => marvell}/mwifiex/sta_tx.c    |    0
 drivers/net/wireless/{ => marvell}/mwifiex/tdls.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/txrx.c  |    0
 .../net/wireless/{ => marvell}/mwifiex/uap_cmd.c   |    0
 .../net/wireless/{ => marvell}/mwifiex/uap_event.c |    0
 .../net/wireless/{ => marvell}/mwifiex/uap_txrx.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/usb.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/usb.h   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/util.c  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/util.h  |    0
 drivers/net/wireless/{ => marvell}/mwifiex/wmm.c   |    0
 drivers/net/wireless/{ => marvell}/mwifiex/wmm.h   |    0
 drivers/net/wireless/{ => marvell}/mwl8k.c         |    0
 drivers/net/wireless/mediatek/Kconfig              |   16 +-
 drivers/net/wireless/ralink/Kconfig                |   16 ++
 drivers/net/wireless/ralink/Makefile               |    1 +
 drivers/net/wireless/{ => ralink}/rt2x00/Kconfig   |    0
 drivers/net/wireless/{ => ralink}/rt2x00/Makefile  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2400pci.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2400pci.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2500pci.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2500pci.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2500usb.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2500usb.h   |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt2800.h  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800lib.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800lib.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800mmio.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800mmio.h  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800pci.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800pci.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800soc.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800usb.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2800usb.h   |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt2x00.h  |    0
 .../wireless/{ => ralink}/rt2x00/rt2x00config.c    |    0
 .../wireless/{ => ralink}/rt2x00/rt2x00crypto.c    |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00debug.c |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00debug.h |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00dev.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00dump.h  |    0
 .../wireless/{ => ralink}/rt2x00/rt2x00firmware.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00leds.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00leds.h  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00lib.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00link.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00mac.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00mmio.c  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00mmio.h  |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00pci.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00pci.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00queue.c |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00queue.h |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00reg.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00soc.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00soc.h   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00usb.c   |    0
 .../net/wireless/{ => ralink}/rt2x00/rt2x00usb.h   |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt61pci.c |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt61pci.h |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt73usb.c |    0
 drivers/net/wireless/{ => ralink}/rt2x00/rt73usb.h |    0
 drivers/net/wireless/realtek/Kconfig               |   18 ++
 drivers/net/wireless/rsi/Kconfig                   |   15 ++
 drivers/net/wireless/st/Kconfig                    |   16 ++
 drivers/net/wireless/st/Makefile                   |    1 +
 drivers/net/wireless/{ => st}/cw1200/Kconfig       |    0
 drivers/net/wireless/{ => st}/cw1200/Makefile      |    0
 drivers/net/wireless/{ => st}/cw1200/bh.c          |    0
 drivers/net/wireless/{ => st}/cw1200/bh.h          |    0
 drivers/net/wireless/{ => st}/cw1200/cw1200.h      |    0
 drivers/net/wireless/{ => st}/cw1200/cw1200_sdio.c |    0
 drivers/net/wireless/{ => st}/cw1200/cw1200_spi.c  |    0
 drivers/net/wireless/{ => st}/cw1200/debug.c       |    0
 drivers/net/wireless/{ => st}/cw1200/debug.h       |    0
 drivers/net/wireless/{ => st}/cw1200/fwio.c        |    0
 drivers/net/wireless/{ => st}/cw1200/fwio.h        |    0
 drivers/net/wireless/{ => st}/cw1200/hwbus.h       |    0
 drivers/net/wireless/{ => st}/cw1200/hwio.c        |    0
 drivers/net/wireless/{ => st}/cw1200/hwio.h        |    0
 drivers/net/wireless/{ => st}/cw1200/main.c        |    0
 drivers/net/wireless/{ => st}/cw1200/pm.c          |    0
 drivers/net/wireless/{ => st}/cw1200/pm.h          |    0
 drivers/net/wireless/{ => st}/cw1200/queue.c       |    0
 drivers/net/wireless/{ => st}/cw1200/queue.h       |    0
 drivers/net/wireless/{ => st}/cw1200/scan.c        |    0
 drivers/net/wireless/{ => st}/cw1200/scan.h        |    0
 drivers/net/wireless/{ => st}/cw1200/sta.c         |    0
 drivers/net/wireless/{ => st}/cw1200/sta.h         |    0
 drivers/net/wireless/{ => st}/cw1200/txrx.c        |    0
 drivers/net/wireless/{ => st}/cw1200/txrx.h        |    0
 drivers/net/wireless/{ => st}/cw1200/wsm.c         |    0
 drivers/net/wireless/{ => st}/cw1200/wsm.h         |    0
 drivers/net/wireless/ti/Kconfig                    |   18 +-
 drivers/net/wireless/ti/wl1251/Kconfig             |    2 +-
 drivers/net/wireless/ti/wlcore/Kconfig             |    2 +-
 drivers/net/wireless/zydas/Kconfig                 |   35 +++
 drivers/net/wireless/zydas/Makefile                |    3 +
 drivers/net/wireless/{ => zydas}/zd1201.c          |    0
 drivers/net/wireless/{ => zydas}/zd1201.h          |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/Kconfig  |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/Makefile |    0
 .../net/wireless/{ => zydas}/zd1211rw/zd_chip.c    |    0
 .../net/wireless/{ => zydas}/zd1211rw/zd_chip.h    |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_def.h |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_mac.c |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_mac.h |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf.c  |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf.h  |    0
 .../wireless/{ => zydas}/zd1211rw/zd_rf_al2230.c   |    0
 .../wireless/{ => zydas}/zd1211rw/zd_rf_al7230b.c  |    0
 .../wireless/{ => zydas}/zd1211rw/zd_rf_rf2959.c   |    0
 .../wireless/{ => zydas}/zd1211rw/zd_rf_uw2453.c   |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_usb.c |    0
 drivers/net/wireless/{ => zydas}/zd1211rw/zd_usb.h |    0
 660 files changed, 511 insertions(+), 314 deletions(-)
 create mode 100644 drivers/net/wireless/admtek/Kconfig
 create mode 100644 drivers/net/wireless/admtek/Makefile
 rename drivers/net/wireless/{ => admtek}/adm8211.c (100%)
 rename drivers/net/wireless/{ => admtek}/adm8211.h (100%)
 create mode 100644 drivers/net/wireless/atmel/Kconfig
 create mode 100644 drivers/net/wireless/atmel/Makefile
 rename drivers/net/wireless/{ => atmel}/at76c50x-usb.c (100%)
 rename drivers/net/wireless/{ => atmel}/at76c50x-usb.h (100%)
 rename drivers/net/wireless/{ => atmel}/atmel.c (100%)
 rename drivers/net/wireless/{ => atmel}/atmel.h (100%)
 rename drivers/net/wireless/{ => atmel}/atmel_cs.c (100%)
 rename drivers/net/wireless/{ => atmel}/atmel_pci.c (100%)
 create mode 100644 drivers/net/wireless/broadcom/Kconfig
 create mode 100644 drivers/net/wireless/broadcom/Makefile
 rename drivers/net/wireless/{ => broadcom}/b43/Kconfig (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/Makefile (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/b43.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/bus.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/bus.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/debugfs.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/debugfs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/dma.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/dma.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/leds.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/leds.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/lo.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/lo.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/main.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/main.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_a.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_a.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_ac.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_ac.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_common.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_common.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_g.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_g.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_ht.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_ht.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_lcn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_lcn.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_lp.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_lp.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_n.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/phy_n.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/pio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/pio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/ppr.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/ppr.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2055.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2055.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2056.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2056.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2057.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2057.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2059.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/radio_2059.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/rfkill.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/rfkill.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/sdio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/sdio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/sysfs.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/sysfs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_lpphy.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_lpphy.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_nphy.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_nphy.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_phy_ht.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_phy_ht.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_phy_lcn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/tables_phy_lcn.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/wa.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/wa.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/xmit.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43/xmit.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/Kconfig (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/Makefile (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/b43legacy.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/debugfs.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/debugfs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/dma.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/dma.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/ilt.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/ilt.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/leds.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/leds.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/main.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/main.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/phy.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/phy.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/pio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/pio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/radio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/radio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/rfkill.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/rfkill.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/sysfs.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/sysfs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/xmit.c (100%)
 rename drivers/net/wireless/{ => broadcom}/b43legacy/xmit.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/Kconfig (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/Makefile (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/Makefile (93%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/bcdc.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/bcdc.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/bcmsdh.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/btcoex.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/btcoex.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/bus.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/cfg80211.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/cfg80211.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/chip.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/chip.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/common.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/common.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/commonring.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/commonring.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/core.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/core.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/debug.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/debug.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/feature.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/feature.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/firmware.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/firmware.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/flowring.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/flowring.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fweh.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fweh.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwil.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwil.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwil_types.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwsignal.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/fwsignal.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/msgbuf.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/msgbuf.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/of.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/of.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/p2p.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/p2p.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/pcie.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/pcie.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/proto.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/proto.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/sdio.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/sdio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/tracepoint.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/tracepoint.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/usb.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/usb.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/vendor.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmfmac/vendor.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/Makefile (88%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/aiutils.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/aiutils.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/ampdu.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/ampdu.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/antsel.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/antsel.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_brcmsmac.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_brcmsmac_msg.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_brcmsmac_tx.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_events.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/brcms_trace_events.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/channel.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/channel.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/d11.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/debug.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/debug.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/dma.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/dma.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/led.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/led.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/mac80211_if.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/mac80211_if.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/main.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/main.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_cmn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_hal.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_int.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_lcn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_lcn.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_n.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_qmath.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_qmath.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phy_radio.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phyreg_n.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phytbl_lcn.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phytbl_lcn.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phytbl_n.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy/phytbl_n.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy_shim.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/phy_shim.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/pmu.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/pmu.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/pub.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/rate.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/rate.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/scb.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/stf.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/stf.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/types.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/ucode_loader.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmsmac/ucode_loader.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmutil/Makefile (89%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmutil/d11.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/brcmutil/utils.c (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/brcm_hw_ids.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/brcmu_d11.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/brcmu_utils.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/brcmu_wifi.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/chipcommon.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/defs.h (100%)
 rename drivers/net/wireless/{ => broadcom}/brcm80211/include/soc.h (100%)
 create mode 100644 drivers/net/wireless/cisco/Kconfig
 create mode 100644 drivers/net/wireless/cisco/Makefile
 rename drivers/net/wireless/{ => cisco}/airo.c (100%)
 rename drivers/net/wireless/{ => cisco}/airo.h (100%)
 rename drivers/net/wireless/{ => cisco}/airo_cs.c (100%)
 create mode 100644 drivers/net/wireless/intel/Kconfig
 create mode 100644 drivers/net/wireless/intel/Makefile
 rename drivers/net/wireless/{ => intel}/ipw2x00/Kconfig (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw.h (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw2100.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw2100.h (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw2200.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/ipw2200.h (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw.h (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_geo.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_module.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_rx.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_tx.c (100%)
 rename drivers/net/wireless/{ => intel}/ipw2x00/libipw_wx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945-debug.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945-mac.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945-rs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/3945.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965-calib.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965-debug.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965-mac.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965-rs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/4965.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/Kconfig (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/commands.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/common.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/common.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/csr.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/debug.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/iwl-spectrum.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlegacy/prph.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/Kconfig (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/agn.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/calib.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/calib.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/commands.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/debugfs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/dev.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/devices.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/led.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/led.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/lib.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/mac80211.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/main.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/power.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/power.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/rs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/rs.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/rx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/rxon.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/scan.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/sta.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/tt.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/tt.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/tx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/dvm/ucode.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-1000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-2000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-5000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-6000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-7000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-8000.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-agn-hw.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-config.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-csr.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-debug.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-debug.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-data.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-io.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-iwlwifi.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-msg.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace-ucode.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-devtrace.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-drv.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-drv.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-eeprom-parse.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-eeprom-parse.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-eeprom-read.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-eeprom-read.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-fh.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-fw-error-dump.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-fw-file.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-fw.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-io.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-io.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-modparams.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-notif-wait.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-notif-wait.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-nvm-parse.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-nvm-parse.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-op-mode.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-phy-db.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-phy-db.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-prph.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-scd.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-trans.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/iwl-trans.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/Makefile (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/binding.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/coex.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/coex_legacy.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/constants.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/d3.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/debugfs-vif.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/debugfs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/debugfs.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-coex.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-d3.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-mac.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-power.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-rs.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-rx.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-scan.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-sta.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-stats.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-tof.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api-tx.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw-api.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/fw.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/led.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/mac-ctxt.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/mac80211.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/mvm.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/nvm.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/offloading.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/ops.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/phy-ctxt.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/power.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/quota.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/rs.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/rs.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/rx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/scan.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/sf.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/sta.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/sta.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tdls.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/testmode.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/time-event.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/time-event.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tof.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tof.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tt.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/tx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/mvm/utils.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/drv.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/internal.h (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/rx.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/trans.c (100%)
 rename drivers/net/wireless/{ => intel}/iwlwifi/pcie/tx.c (100%)
 create mode 100644 drivers/net/wireless/intersil/Kconfig
 create mode 100644 drivers/net/wireless/intersil/Makefile
 rename drivers/net/wireless/{ => intersil}/hostap/Kconfig (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/Makefile (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_80211.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_80211_rx.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_80211_tx.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_ap.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_ap.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_common.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_config.h (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_cs.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_download.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_hw.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_info.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_ioctl.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_main.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_pci.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_plx.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_proc.c (100%)
 rename drivers/net/wireless/{ => intersil}/hostap/hostap_wlan.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/Kconfig (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/Makefile (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/airport.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/cfg.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/cfg.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/fw.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/fw.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes_dld.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes_dld.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hermes_rid.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hw.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/hw.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/main.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/main.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/mic.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/mic.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_cs.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_nortel.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_pci.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_pci.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_plx.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_tmd.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/orinoco_usb.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/scan.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/scan.h (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/spectrum_cs.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/wext.c (100%)
 rename drivers/net/wireless/{ => intersil}/orinoco/wext.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/Kconfig (100%)
 rename drivers/net/wireless/{ => intersil}/p54/Makefile (100%)
 rename drivers/net/wireless/{ => intersil}/p54/eeprom.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/eeprom.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/fwio.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/led.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/lmac.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/main.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54pci.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54pci.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54spi.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54spi.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54spi_eeprom.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54usb.c (100%)
 rename drivers/net/wireless/{ => intersil}/p54/p54usb.h (100%)
 rename drivers/net/wireless/{ => intersil}/p54/txrx.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/Makefile (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_38xx.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_38xx.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_ioctl.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_ioctl.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/isl_oid.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_dev.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_dev.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_eth.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_eth.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_hotplug.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_mgt.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/islpci_mgt.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/oid_mgt.c (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/oid_mgt.h (100%)
 rename drivers/net/wireless/{ => intersil}/prism54/prismcompat.h (100%)
 create mode 100644 drivers/net/wireless/marvell/Kconfig
 create mode 100644 drivers/net/wireless/marvell/Makefile
 rename drivers/net/wireless/{ => marvell}/libertas/Kconfig (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/LICENSE (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/Makefile (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/README (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cfg.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cfg.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cmd.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cmd.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/cmdresp.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/debugfs.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/debugfs.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/decl.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/defs.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/dev.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/ethtool.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/firmware.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/host.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_cs.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_sdio.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_sdio.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_spi.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_spi.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_usb.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/if_usb.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/main.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/mesh.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/mesh.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/radiotap.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/rx.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/tx.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas/types.h (100%)
 create mode 100644 drivers/net/wireless/marvell/libertas_tf/Kconfig
 rename drivers/net/wireless/{ => marvell}/libertas_tf/Makefile (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/cmd.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/deb_defs.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/if_usb.c (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/if_usb.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/libertas_tf.h (100%)
 rename drivers/net/wireless/{ => marvell}/libertas_tf/main.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11ac.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11ac.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11h.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n_aggr.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n_aggr.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n_rxreorder.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/11n_rxreorder.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/Kconfig (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/Makefile (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/README (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/cfg80211.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/cfg80211.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/cfp.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/cmdevt.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/debugfs.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/decl.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/ethtool.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/fw.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/ie.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/init.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/ioctl.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/join.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/main.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/main.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/pcie.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/pcie.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/scan.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sdio.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sdio.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_cmd.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_cmdresp.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_event.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_ioctl.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_rx.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/sta_tx.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/tdls.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/txrx.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/uap_cmd.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/uap_event.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/uap_txrx.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/usb.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/usb.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/util.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/util.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/wmm.c (100%)
 rename drivers/net/wireless/{ => marvell}/mwifiex/wmm.h (100%)
 rename drivers/net/wireless/{ => marvell}/mwl8k.c (100%)
 create mode 100644 drivers/net/wireless/ralink/Kconfig
 create mode 100644 drivers/net/wireless/ralink/Makefile
 rename drivers/net/wireless/{ => ralink}/rt2x00/Kconfig (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/Makefile (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2400pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2400pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2500pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2500pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2500usb.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2500usb.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800lib.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800lib.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800mmio.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800mmio.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800soc.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800usb.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2800usb.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00config.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00crypto.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00debug.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00debug.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00dev.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00dump.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00firmware.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00leds.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00leds.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00lib.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00link.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00mac.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00mmio.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00mmio.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00queue.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00queue.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00reg.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00soc.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00soc.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00usb.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt2x00usb.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt61pci.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt61pci.h (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt73usb.c (100%)
 rename drivers/net/wireless/{ => ralink}/rt2x00/rt73usb.h (100%)
 create mode 100644 drivers/net/wireless/realtek/Kconfig
 create mode 100644 drivers/net/wireless/st/Kconfig
 create mode 100644 drivers/net/wireless/st/Makefile
 rename drivers/net/wireless/{ => st}/cw1200/Kconfig (100%)
 rename drivers/net/wireless/{ => st}/cw1200/Makefile (100%)
 rename drivers/net/wireless/{ => st}/cw1200/bh.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/bh.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/cw1200.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/cw1200_sdio.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/cw1200_spi.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/debug.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/debug.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/fwio.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/fwio.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/hwbus.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/hwio.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/hwio.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/main.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/pm.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/pm.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/queue.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/queue.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/scan.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/scan.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/sta.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/sta.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/txrx.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/txrx.h (100%)
 rename drivers/net/wireless/{ => st}/cw1200/wsm.c (100%)
 rename drivers/net/wireless/{ => st}/cw1200/wsm.h (100%)
 create mode 100644 drivers/net/wireless/zydas/Kconfig
 create mode 100644 drivers/net/wireless/zydas/Makefile
 rename drivers/net/wireless/{ => zydas}/zd1201.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1201.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/Kconfig (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/Makefile (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_chip.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_chip.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_def.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_mac.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_mac.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf.h (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf_al2230.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf_al7230b.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf_rf2959.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_rf_uw2453.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_usb.c (100%)
 rename drivers/net/wireless/{ => zydas}/zd1211rw/zd_usb.h (100%)
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
