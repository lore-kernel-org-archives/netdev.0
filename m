From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 00/12] Part 2: check given MAC address, if invalid return -EADDRNOTAVAIL
Date: Fri, 24 Feb 2012 17:01:10 +0100
Message-ID: <1330099282-4588-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	libertas-dev@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-media@vger.kernel.org, linux-s390@vger.kernel.org,
	linux-hams@vger.kernel.org, linux-mips@linux-mips.org
To: "David S. Miller" <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Guo-Fu Tseng <cooldavid@cooldavid.org>,
	Petko Manolov <petkan@users.sourceforge.net>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"John W. Linville" <linville@tuxdriver.com>, linux390@de.ibm.com,
	Mauro Carvalho Chehab <mchehab@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Second Part of series patches to unifiy the return value of 
.ndo_set_mac_address if the given address isn't valid.

These changes check if a given (MAC) address is valid in 
.ndo_set_mac_address, if invalid return -EADDRNOTAVAIL 
as eth_mac_addr() already does if is_valid_ether_addr() fails.

These patches are against net-next.

Danny Kukawka (12):
  ethernet: .ndo_set_mac_address: check given address, if invalid
    return -EADDRNOTAVAIL
  cris/eth_v10: check given MAC address, if invalid return
    -EADDRNOTAVAIL
  dvb_net: check given MAC address, if invalid return -EADDRNOTAVAIL
  fddi/skfp: check given MAC address, if invalid return -EADDRNOTAVAIL
  team: check given MAC address, if invalid return -EADDRNOTAVAIL
  tokenring: check given MAC address, if invalid return -EADDRNOTAVAIL
  usb/rtl8150: check given MAC address, if invalid return
    -EADDRNOTAVAIL
  vmxnet3: check given MAC address, if invalid return -EADDRNOTAVAIL
  wan/lapbether: check given MAC address, if invalid return
    -EADDRNOTAVAIL
  wireless: check given MAC address, if invalid return -EADDRNOTAVAIL
  s390/net/qeth_l2_main: check given MAC address, if invalid return
    -EADDRNOTAVAIL
  rose: check given MAC address, if invalid return -EADDRNOTAVAIL

 drivers/media/dvb/dvb-core/dvb_net.c               |    5 ++++-
 drivers/net/cris/eth_v10.c                         |    3 +++
 drivers/net/ethernet/amd/amd8111e.c                |    3 +++
 drivers/net/ethernet/amd/atarilance.c              |    3 +++
 drivers/net/ethernet/chelsio/cxgb/cxgb2.c          |    3 +++
 drivers/net/ethernet/cisco/enic/enic_main.c        |    3 +++
 drivers/net/ethernet/freescale/fec_mpc52xx.c       |    3 +++
 drivers/net/ethernet/jme.c                         |    3 +++
 drivers/net/ethernet/micrel/ks8851_mll.c           |    3 +++
 drivers/net/ethernet/micrel/ksz884x.c              |    3 +++
 drivers/net/ethernet/seeq/sgiseeq.c                |    3 +++
 drivers/net/ethernet/sgi/ioc3-eth.c                |    3 +++
 drivers/net/ethernet/tehuti/tehuti.c               |    3 +++
 drivers/net/fddi/skfp/skfddi.c                     |    3 +++
 drivers/net/team/team.c                            |    3 +++
 drivers/net/tokenring/3c359.c                      |    4 ++++
 drivers/net/tokenring/lanstreamer.c                |    4 ++++
 drivers/net/tokenring/olympic.c                    |    4 ++++
 drivers/net/tokenring/tms380tr.c                   |    3 +++
 drivers/net/usb/rtl8150.c                          |    3 +++
 drivers/net/vmxnet3/vmxnet3_drv.c                  |    3 +++
 drivers/net/wan/lapbether.c                        |    5 +++++
 drivers/net/wireless/airo.c                        |    3 +++
 drivers/net/wireless/atmel.c                       |    3 +++
 .../net/wireless/brcm80211/brcmfmac/dhd_linux.c    |    5 ++++-
 drivers/net/wireless/hostap/hostap_main.c          |    3 +++
 drivers/net/wireless/libertas/main.c               |    3 +++
 drivers/net/wireless/mwifiex/main.c                |    3 +++
 drivers/net/wireless/zd1201.c                      |    2 ++
 drivers/s390/net/qeth_l2_main.c                    |    3 +++
 net/rose/rose_dev.c                                |    3 +++
 31 files changed, 99 insertions(+), 2 deletions(-)

-- 
1.7.8.3
