From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH NEXT 00/17] rtlwifi: Add new driver for RTL8723AE
Date: Thu, 25 Oct 2012 13:46:29 -0500
Message-ID: <1351190806-4258-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This set of patches is based on the wireless-next tree.

The first patch modifies driver rtl8192ce to work with the newest set of
RTL8188CE-VL devices, which have built-in Bluetooth capability. This
patch was previously submitted but was discarded because it had a merge
problem.

The rest of the patches in this set introduce a new driver for the rtlwifi
family that handles the RTL8723AE device.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>

Larry Finger (17):
  rtlwifi: rtl8192c: rtl8192ce: Add support for B-CUT version of
    RTL8188CE
  rtlwifi: rtl8192c: rtl8192ce: rtl8192cu: rtl8192se: rtl8192de:
    Shorten some variable names
  rtlwifi: rtl8723ae: Add new driver - Part 1
  rtlwifi: rtl8723ae: Add new driver - Part 2
  rtlwifi: rtl8723ae: Add new driver - Part 3
  rtlwifi: rtl8723ae: Add new driver - Part 4
  rtlwifi: rtl8723ae: Add new driver - Part 5
  rtlwifi: rtl8723ae: Add new driver - Part 6
  rtlwifi: rtl8723ae: Add new driver - Part 7
  rtlwifi: rtl8723ae: Add new driver - Part 8
  rtlwifi: rtl8723ae: Add new driver - Part 9
  rtlwifi: rtl8723ae: Add new driver - Part 10
  rtlwifi: rtl8723ae: Add new driver - Part 11
  rtlwifi: rtl8723ae: Add new driver - Part 12
  rtlwifi: rtl8723ae: Add new driver - Part 13
  rtlwifi: Modify files for addition of rtl8723ae
  rtlwifi: rtl8192ce: rtl8192cu: rtl8192se: rtl81723ae: Turn on
    building of the new driver

 drivers/net/wireless/rtlwifi/Kconfig               |   11 +
 drivers/net/wireless/rtlwifi/Makefile              |    4 +-
 drivers/net/wireless/rtlwifi/base.c                |   24 +
 drivers/net/wireless/rtlwifi/base.h                |    2 +
 drivers/net/wireless/rtlwifi/debug.h               |    2 +
 drivers/net/wireless/rtlwifi/pci.c                 |   20 +-
 drivers/net/wireless/rtlwifi/pci.h                 |    2 +
 drivers/net/wireless/rtlwifi/rc.c                  |    3 +-
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |  227 +-
 drivers/net/wireless/rtlwifi/rtl8192c/phy_common.c |   88 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h       |    3 +
 drivers/net/wireless/rtlwifi/rtl8192ce/dm.c        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   87 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/phy.c       |    2 +
 drivers/net/wireless/rtlwifi/rtl8192ce/rf.c        |   23 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |   46 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/dm.c        |   30 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   10 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/mac.c       |   25 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/rf.c        |   22 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |   95 +-
 drivers/net/wireless/rtlwifi/rtl8192de/phy.c       |   65 +-
 drivers/net/wireless/rtlwifi/rtl8192de/rf.c        |   18 +-
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |   39 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |   89 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |   64 +-
 drivers/net/wireless/rtlwifi/rtl8192se/rf.c        |   11 +-
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |   21 +-
 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile    |   22 +
 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h       |   41 +
 drivers/net/wireless/rtlwifi/rtl8723ae/def.h       |  163 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c        |  920 ++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h        |  149 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c        |  745 ++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h        |  101 +
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c    |  542 +++++
 .../wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h    |  160 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c   | 1786 +++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h   |  151 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c        | 2380 ++++++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h        |   73 +
 drivers/net/wireless/rtlwifi/rtl8723ae/led.c       |  151 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/led.h       |   39 +
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c       | 2044 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h       |  224 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c    |  109 +
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h    |  322 +++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c |  129 ++
 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h |   98 +
 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h       | 2097 +++++++++++++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c        |  505 +++++
 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h        |   43 +
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c        |  387 ++++
 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h        |   37 +
 drivers/net/wireless/rtlwifi/rtl8723ae/table.c     |  738 ++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/table.h     |   50 +
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c       |  670 ++++++
 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h       |  725 ++++++
 drivers/net/wireless/rtlwifi/stats.c               |  268 +++
 drivers/net/wireless/rtlwifi/stats.h               |   46 +
 drivers/net/wireless/rtlwifi/wifi.h                |  161 +-
 63 files changed, 16579 insertions(+), 572 deletions(-)
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/Makefile
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/def.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/dm.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/dm.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/fw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/fw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_bt_coexist.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hal_btc.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/hw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/led.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/led.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/phy.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/phy.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseq.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/pwrseqcmd.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/reg.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/rf.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/rf.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/sw.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/sw.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/table.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/table.h
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/trx.c
 create mode 100644 drivers/net/wireless/rtlwifi/rtl8723ae/trx.h
 create mode 100644 drivers/net/wireless/rtlwifi/stats.c
 create mode 100644 drivers/net/wireless/rtlwifi/stats.h

-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
