From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 0/4] New driver for Realtek RTL8192EE
Date: Wed, 21 May 2014 16:25:32 -0500
Message-ID: <1400707536-3338-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org, troy_tan@realsil.com.cn,
 zhangfp1@lenovo.com, Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

The RTL8192EE is a new wireless device that is being shipped in Lenovo T440s
tablets. Merging of this driver was hurried so that users of this device would
have wireless connections.

A kernel image that includes this driver has been made available on my FTP site
for about 10 days, and the problems have been fixed. The code needs additional
polishing before it can be merged into the regular wireless tree; however,
that should not take more than a single cycle.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>


Larry Finger (4):
  staging: r8192ee: Add source files for core driver
  staging: r8192ee: Add code for Bluetooth coexistence
  staging: r8192ee: Add the files in the rtl8192ee directory
  staging: r8192ee: Turn on build of the new driver

 drivers/staging/Kconfig                            |    2 +
 drivers/staging/Makefile                           |    1 +
 drivers/staging/rtl8192ee/Kconfig                  |    8 +
 drivers/staging/rtl8192ee/Makefile                 |   40 +
 drivers/staging/rtl8192ee/TODO                     |   12 +
 drivers/staging/rtl8192ee/base.c                   | 1852 +++++++++
 drivers/staging/rtl8192ee/base.h                   |  163 +
 .../staging/rtl8192ee/btcoexist/halbt_precomp.h    |   50 +
 .../staging/rtl8192ee/btcoexist/halbtc8192e2ant.c  | 4110 ++++++++++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8192e2ant.h  |  161 +
 .../staging/rtl8192ee/btcoexist/halbtc8723b1ant.c  | 3146 +++++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8723b1ant.h  |  160 +
 .../staging/rtl8192ee/btcoexist/halbtc8723b2ant.c  | 3929 +++++++++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8723b2ant.h  |  145 +
 .../staging/rtl8192ee/btcoexist/halbtc8821a1ant.c  | 2780 +++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8821a1ant.h  |  158 +
 .../staging/rtl8192ee/btcoexist/halbtc8821a2ant.c  | 3438 ++++++++++++++++
 .../staging/rtl8192ee/btcoexist/halbtc8821a2ant.h  |  179 +
 drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c | 1307 +++++++
 drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.h |  537 +++
 drivers/staging/rtl8192ee/btcoexist/rtl_btc.c      |  194 +
 drivers/staging/rtl8192ee/btcoexist/rtl_btc.h      |   62 +
 drivers/staging/rtl8192ee/cam.c                    |  337 ++
 drivers/staging/rtl8192ee/cam.h                    |   52 +
 drivers/staging/rtl8192ee/compat.h                 |   70 +
 drivers/staging/rtl8192ee/core.c                   | 1600 ++++++++
 drivers/staging/rtl8192ee/core.h                   |   39 +
 drivers/staging/rtl8192ee/debug.c                  |  978 +++++
 drivers/staging/rtl8192ee/debug.h                  |  221 ++
 drivers/staging/rtl8192ee/efuse.c                  | 1233 ++++++
 drivers/staging/rtl8192ee/efuse.h                  |  127 +
 drivers/staging/rtl8192ee/pci.c                    | 2397 ++++++++++++
 drivers/staging/rtl8192ee/pci.h                    |  342 ++
 drivers/staging/rtl8192ee/ps.c                     |  983 +++++
 drivers/staging/rtl8192ee/ps.h                     |   52 +
 drivers/staging/rtl8192ee/rc.c                     |  288 ++
 drivers/staging/rtl8192ee/rc.h                     |   47 +
 drivers/staging/rtl8192ee/regd.c                   |  448 +++
 drivers/staging/rtl8192ee/regd.h                   |   63 +
 drivers/staging/rtl8192ee/rtl8192ee/def.h          |  106 +
 drivers/staging/rtl8192ee/rtl8192ee/dm.c           | 1258 ++++++
 drivers/staging/rtl8192ee/rtl8192ee/dm.h           |  343 ++
 drivers/staging/rtl8192ee/rtl8192ee/fw.c           |  945 +++++
 drivers/staging/rtl8192ee/rtl8192ee/fw.h           |  213 +
 drivers/staging/rtl8192ee/rtl8192ee/hw.c           | 2544 ++++++++++++
 drivers/staging/rtl8192ee/rtl8192ee/hw.h           |   67 +
 drivers/staging/rtl8192ee/rtl8192ee/led.c          |  134 +
 drivers/staging/rtl8192ee/rtl8192ee/led.h          |   37 +
 drivers/staging/rtl8192ee/rtl8192ee/phy.c          | 3282 ++++++++++++++++
 drivers/staging/rtl8192ee/rtl8192ee/phy.h          |  154 +
 drivers/staging/rtl8192ee/rtl8192ee/pwrseq.c       |  108 +
 drivers/staging/rtl8192ee/rtl8192ee/pwrseq.h       |  355 ++
 drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.c    |  139 +
 drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.h    |   69 +
 drivers/staging/rtl8192ee/rtl8192ee/reg.h          | 2240 +++++++++++
 drivers/staging/rtl8192ee/rtl8192ee/rf.c           |  150 +
 drivers/staging/rtl8192ee/rtl8192ee/rf.h           |   39 +
 drivers/staging/rtl8192ee/rtl8192ee/sw.c           |  428 ++
 drivers/staging/rtl8192ee/rtl8192ee/sw.h           |   39 +
 drivers/staging/rtl8192ee/rtl8192ee/table.c        |  882 +++++
 drivers/staging/rtl8192ee/rtl8192ee/table.h        |   48 +
 drivers/staging/rtl8192ee/rtl8192ee/trx.c          | 1286 ++++++
 drivers/staging/rtl8192ee/rtl8192ee/trx.h          |  877 +++++
 drivers/staging/rtl8192ee/stats.c                  |  290 ++
 drivers/staging/rtl8192ee/stats.h                  |   43 +
 drivers/staging/rtl8192ee/wifi.h                   | 2645 +++++++++++++
 66 files changed, 50432 insertions(+)
 create mode 100644 drivers/staging/rtl8192ee/Kconfig
 create mode 100644 drivers/staging/rtl8192ee/Makefile
 create mode 100644 drivers/staging/rtl8192ee/TODO
 create mode 100644 drivers/staging/rtl8192ee/base.c
 create mode 100644 drivers/staging/rtl8192ee/base.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbt_precomp.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8192e2ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8723b1ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8723b2ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8821a1ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtc8821a2ant.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/halbtcoutsrc.h
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/rtl_btc.c
 create mode 100644 drivers/staging/rtl8192ee/btcoexist/rtl_btc.h
 create mode 100644 drivers/staging/rtl8192ee/cam.c
 create mode 100644 drivers/staging/rtl8192ee/cam.h
 create mode 100644 drivers/staging/rtl8192ee/compat.h
 create mode 100644 drivers/staging/rtl8192ee/core.c
 create mode 100644 drivers/staging/rtl8192ee/core.h
 create mode 100644 drivers/staging/rtl8192ee/debug.c
 create mode 100644 drivers/staging/rtl8192ee/debug.h
 create mode 100644 drivers/staging/rtl8192ee/efuse.c
 create mode 100644 drivers/staging/rtl8192ee/efuse.h
 create mode 100644 drivers/staging/rtl8192ee/pci.c
 create mode 100644 drivers/staging/rtl8192ee/pci.h
 create mode 100644 drivers/staging/rtl8192ee/ps.c
 create mode 100644 drivers/staging/rtl8192ee/ps.h
 create mode 100644 drivers/staging/rtl8192ee/rc.c
 create mode 100644 drivers/staging/rtl8192ee/rc.h
 create mode 100644 drivers/staging/rtl8192ee/regd.c
 create mode 100644 drivers/staging/rtl8192ee/regd.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/def.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/dm.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/dm.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/fw.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/fw.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/hw.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/hw.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/led.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/led.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/phy.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/phy.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/pwrseq.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/pwrseq.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/pwrseqcmd.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/reg.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/rf.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/rf.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/sw.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/sw.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/table.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/table.h
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/trx.c
 create mode 100644 drivers/staging/rtl8192ee/rtl8192ee/trx.h
 create mode 100644 drivers/staging/rtl8192ee/stats.c
 create mode 100644 drivers/staging/rtl8192ee/stats.h
 create mode 100644 drivers/staging/rtl8192ee/wifi.h

-- 
1.8.4.5
