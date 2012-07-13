From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 0/8] etherdevice: Rename random_ether_addr to eth_random_addr
Date: Thu, 12 Jul 2012 22:33:04 -0700
Message-ID: <cover.1342157022.git.joe@perches.com>
References: <1341968967.13724.23.camel@joe2Laptop>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	uclinux-dist-devel@blackfin.uclinux.org,
	linux-kernel@vger.kernel.org, linux-c6x-dev@linux-c6x.org,
	linux-mips@linux-mips.org,
	user-mode-linux-devel@lists.sourceforge.net,
	user-mode-linux-user@lists.sourceforge.net,
	e1000-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, wimax@linuxwimax.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	linux-s390@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1341968967.13724.23.camel@joe2Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net-next commit ad7eee98be ("etherdevice: introduce eth_broadcast_addr")
added a new style API.  Rename random_ether_addr to eth_random_addr to
create some API symmetry.

Joe Perches (8):
  etherdevice: Rename random_ether_addr to eth_random_addr
  ethernet: Use eth_random_addr
  net: usb: Use eth_random_addr
  wireless: Use eth_random_addr
  drivers/net: Use eth_random_addr
  s390: Use eth_random_addr
  usb: Use eth_random_addr
  arch: Use eth_random_addr

 arch/blackfin/mach-bf537/boards/stamp.c           |    2 +-
 arch/c6x/kernel/soc.c                             |    2 +-
 arch/mips/ar7/platform.c                          |    4 ++--
 arch/mips/powertv/powertv_setup.c                 |    6 +++---
 arch/um/drivers/net_kern.c                        |    2 +-
 drivers/net/ethernet/atheros/atl1c/atl1c_hw.c     |    2 +-
 drivers/net/ethernet/atheros/atlx/atl1.c          |    2 +-
 drivers/net/ethernet/atheros/atlx/atl2.c          |    2 +-
 drivers/net/ethernet/ethoc.c                      |    2 +-
 drivers/net/ethernet/intel/igb/igb_main.c         |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    |    2 +-
 drivers/net/ethernet/lantiq_etop.c                |    2 +-
 drivers/net/ethernet/micrel/ks8851.c              |    2 +-
 drivers/net/ethernet/micrel/ks8851_mll.c          |    2 +-
 drivers/net/ethernet/smsc/smsc911x.c              |    2 +-
 drivers/net/ethernet/ti/cpsw.c                    |    2 +-
 drivers/net/ethernet/tile/tilegx.c                |    2 +-
 drivers/net/ethernet/wiznet/w5100.c               |    2 +-
 drivers/net/ethernet/wiznet/w5300.c               |    2 +-
 drivers/net/ethernet/xilinx/xilinx_axienet_main.c |    2 +-
 drivers/net/tun.c                                 |    2 +-
 drivers/net/usb/smsc75xx.c                        |    2 +-
 drivers/net/usb/smsc95xx.c                        |    2 +-
 drivers/net/usb/usbnet.c                          |    2 +-
 drivers/net/wimax/i2400m/driver.c                 |    2 +-
 drivers/net/wireless/adm8211.c                    |    2 +-
 drivers/net/wireless/p54/eeprom.c                 |    2 +-
 drivers/net/wireless/rt2x00/rt2400pci.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2500pci.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2500usb.c           |    2 +-
 drivers/net/wireless/rt2x00/rt2800lib.c           |    2 +-
 drivers/net/wireless/rt2x00/rt61pci.c             |    2 +-
 drivers/net/wireless/rt2x00/rt73usb.c             |    2 +-
 drivers/net/wireless/rtl818x/rtl8180/dev.c        |    2 +-
 drivers/net/wireless/rtl818x/rtl8187/dev.c        |    2 +-
 drivers/s390/net/qeth_l2_main.c                   |    2 +-
 drivers/s390/net/qeth_l3_main.c                   |    2 +-
 drivers/usb/atm/xusbatm.c                         |    4 ++--
 drivers/usb/gadget/u_ether.c                      |    2 +-
 include/linux/etherdevice.h                       |   14 ++++++++------
 40 files changed, 52 insertions(+), 50 deletions(-)

-- 
1.7.8.111.gad25c.dirty
