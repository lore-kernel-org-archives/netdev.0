From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Tue, 18 Sep 2007 21:50:01 -0700
Message-ID: <1190177401.19708.264.camel@localhost>
References: <20070828.142216.99461544.davem@davemloft.net>
	 <1188598563.6062.191.camel@localhost>
	 <1189798908.19708.170.camel@localhost>
	 <20070917.190527.42775386.davem@davemloft.net>
	 <1190081655.19708.255.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1645 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751039AbXISEvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Sep 2007 00:51:42 -0400
In-Reply-To: <1190081655.19708.255.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-09-17 at 19:14 -0700, Joe Perches wrote:
> On Mon, 2007-09-17 at 19:05 -0700, David Miller wrote:
> > Anyways, it would indeed help if you could rebase the patch
> > against net-2.6.24  It would save me a ton of time.
> 
> I'll rebase it tomorrow against whatever's in
> your current net-2.6.24.

I rebased against yesterday's net-2.6.24

Please pull from:

git://repo.or.cz/linux-2.6/trivial-mods.git net-2.6.24-fordave

 drivers/net/3c503.c                            |    4 +-
 drivers/net/3c505.c                            |   10 +-
 drivers/net/3c507.c                            |    6 +-
 drivers/net/3c509.c                            |   18 +--
 drivers/net/3c515.c                            |    4 +-
 drivers/net/3c523.c                            |   22 +--
 drivers/net/3c527.c                            |    7 +-
 drivers/net/3c59x.c                            |    7 +-
 drivers/net/8139cp.c                           |    8 +-
 drivers/net/8139too.c                          |    8 +-
 drivers/net/82596.c                            |   18 +--
 drivers/net/a2065.c                            |    6 +-
 drivers/net/ac3200.c                           |    8 +-
 drivers/net/acenic.c                           |    7 +-
 drivers/net/amd8111e.c                         |   12 +-
 drivers/net/apne.c                             |    9 +-
 drivers/net/ariadne.c                          |   44 +++---
 drivers/net/arm/am79c961a.c                    |    8 +-
 drivers/net/arm/at91_ether.c                   |   18 +-
 drivers/net/arm/ether1.c                       |    8 +-
 drivers/net/arm/ether3.c                       |    8 +-
 drivers/net/arm/etherh.c                       |    8 +-
 drivers/net/at1700.c                           |    4 +-
 drivers/net/atarilance.c                       |   43 +++---
 drivers/net/atp.c                              |    8 +-
 drivers/net/b44.c                              |    9 +-
 drivers/net/bmac.c                             |    6 +-
 drivers/net/bnx2.c                             |   12 +-
 drivers/net/bonding/bond_main.c                |   34 ++---
 drivers/net/bonding/bond_sysfs.c               |   11 +-
 drivers/net/cassini.c                          |   11 +-
 drivers/net/cris/eth_v10.c                     |    8 +-
 drivers/net/cs89x0.c                           |   15 +--
 drivers/net/de600.c                            |    6 +-
 drivers/net/de620.c                            |    8 +-
 drivers/net/declance.c                         |   14 +-
 drivers/net/depca.c                            |   13 +-
 drivers/net/dgrs.c                             |   18 +--
 drivers/net/dl2k.c                             |    7 +-
 drivers/net/dm9000.c                           |    9 +-
 drivers/net/e100.c                             |    9 +-
 drivers/net/e1000/e1000_main.c                 |    5 +-
 drivers/net/eepro.c                            |    5 +-
 drivers/net/eepro100.c                         |    9 +-
 drivers/net/epic100.c                          |    9 +-
 drivers/net/es3210.c                           |   22 ++--
 drivers/net/ewrk3.c                            |   16 +--
 drivers/net/fealnx.c                           |    9 +-
 drivers/net/fec.c                              |    7 +-
 drivers/net/forcedeth.c                        |   12 +-
 drivers/net/gianfar.c                          |    7 +-
 drivers/net/hamachi.c                          |    8 +-
 drivers/net/hamradio/bpqether.c                |   23 +--
 drivers/net/hp-plus.c                          |    6 +-
 drivers/net/hp.c                               |    5 +-
 drivers/net/hp100.c                            |    6 +-
 drivers/net/hydra.c                            |    7 +-
 drivers/net/ibm_emac/ibm_emac_core.c           |   14 +-
 drivers/net/ibmlana.c                          |    6 +-
 drivers/net/ibmveth.c                          |    9 +-
 drivers/net/ioc3-eth.c                         |   12 +-
 drivers/net/isa-skeleton.c                     |    5 +-
 drivers/net/jazzsonic.c                        |   10 +-
 drivers/net/lance.c                            |    6 +-
 drivers/net/lguest_net.c                       |    4 +-
 drivers/net/lib82596.c                         |   18 +--
 drivers/net/lne390.c                           |    9 +-
 drivers/net/mac89x0.c                          |   11 +-
 drivers/net/macb.c                             |    6 +-
 drivers/net/mace.c                             |    9 +-
 drivers/net/macmace.c                          |    6 +-
 drivers/net/macsonic.c                         |   21 +--
 drivers/net/meth.c                             |    6 +-
 drivers/net/mv643xx_eth.c                      |    5 +-
 drivers/net/mvme147.c                          |   11 +-
 drivers/net/myri10ge/myri10ge.c                |   11 +-
 drivers/net/myri_sbus.c                        |   29 ++---
 drivers/net/natsemi.c                          |   11 +-
 drivers/net/ne-h8300.c                         |    8 +-
 drivers/net/ne.c                               |    5 +-
 drivers/net/ne2.c                              |   17 +--
 drivers/net/ne2k-pci.c                         |   11 +-
 drivers/net/ne3210.c                           |   11 +-
 drivers/net/netconsole.c                       |   14 +-
 drivers/net/netxen/netxen_nic_main.c           |   13 +-
 drivers/net/netxen/netxen_nic_niu.c            |   14 +-
 drivers/net/ni5010.c                           |    4 +-
 drivers/net/ns83820.c                          |    7 +-
 drivers/net/pasemi_mac.c                       |    6 +-
 drivers/net/pci-skeleton.c                     |    9 +-
 drivers/net/pcmcia/3c574_cs.c                  |    9 +-
 drivers/net/pcmcia/3c589_cs.c                  |   10 +-
 drivers/net/pcmcia/axnet_cs.c                  |    9 +-
 drivers/net/pcmcia/fmvj18x_cs.c                |    8 +-
 drivers/net/pcmcia/nmclan_cs.c                 |    9 +-
 drivers/net/pcmcia/pcnet_cs.c                  |    7 +-
 drivers/net/pcmcia/smc91c92_cs.c               |    8 +-
 drivers/net/pcmcia/xirc2ps_cs.c                |    9 +-
 drivers/net/pppoe.c                            |    8 +-
 drivers/net/ps3_gelic_net.c                    |    7 +-
 drivers/net/qla3xxx.c                          |    7 +-
 drivers/net/rionet.c                           |    6 +-
 drivers/net/rrunner.c                          |    8 +-
 drivers/net/s2io.c                             |   11 +-
 drivers/net/sb1250-mac.c                       |    7 +-
 drivers/net/seeq8005.c                         |    4 +-
 drivers/net/sgiseeq.c                          |    6 +-
 drivers/net/sis190.c                           |   10 +-
 drivers/net/sis900.c                           |    9 +-
 drivers/net/skge.c                             |    7 +-
 drivers/net/sky2.c                             |    7 +-
 drivers/net/smc-mca.c                          |    8 +-
 drivers/net/smc-ultra.c                        |    8 +-
 drivers/net/smc-ultra32.c                      |    8 +-
 drivers/net/smc9194.c                          |    7 +-
 drivers/net/smc91x.c                           |    9 +-
 drivers/net/starfire.c                         |   26 ++--
 drivers/net/sun3lance.c                        |   36 ++---
 drivers/net/sunbmac.c                          |    8 +-
 drivers/net/sundance.c                         |   10 +-
 drivers/net/sungem.c                           |   12 +-
 drivers/net/sunhme.c                           |   12 +-
 drivers/net/sunlance.c                         |    9 +-
 drivers/net/tokenring/abyss.c                  |   12 +-
 drivers/net/tokenring/ibmtr.c                  |   26 ++--
 drivers/net/tokenring/lanstreamer.c            |   64 +++-----
 drivers/net/tokenring/madgemc.c                |   19 +--
 drivers/net/tokenring/olympic.c                |  138 +++++++---------
 drivers/net/tokenring/proteon.c                |    8 +-
 drivers/net/tokenring/skisa.c                  |    8 +-
 drivers/net/tokenring/tmspci.c                 |   10 +-
 drivers/net/tsi108_eth.c                       |    7 +-
 drivers/net/tulip/de2104x.c                    |    9 +-
 drivers/net/tulip/de4x5.c                      |   33 +---
 drivers/net/tulip/dmfe.c                       |   15 +-
 drivers/net/tulip/tulip_core.c                 |   15 +-
 drivers/net/tulip/uli526x.c                    |    9 +-
 drivers/net/tulip/winbond-840.c                |   29 ++--
 drivers/net/tulip/xircom_cb.c                  |    7 +-
 drivers/net/tun.c                              |   33 ++---
 drivers/net/typhoon.c                          |   10 +-
 drivers/net/usb/pegasus.c                      |   11 +-
 drivers/net/usb/usbnet.c                       |    8 +-
 drivers/net/via-rhine.c                        |   13 +-
 drivers/net/wd.c                               |    7 +-
 drivers/net/wireless/adm8211.c                 |    5 +-
 drivers/net/wireless/airo.c                    |   32 ++---
 drivers/net/wireless/arlan-main.c              |   23 ++--
 drivers/net/wireless/atmel.c                   |    7 +-
 drivers/net/wireless/bcm43xx/bcm43xx.h         |    6 -
 drivers/net/wireless/hostap/hostap_80211_rx.c  |   49 ++++---
 drivers/net/wireless/hostap/hostap_80211_tx.c  |   13 +-
 drivers/net/wireless/hostap/hostap_ap.c        |  198 +++++++++++++----------
 drivers/net/wireless/hostap/hostap_common.h    |    3 -
 drivers/net/wireless/hostap/hostap_hw.c        |   11 +-
 drivers/net/wireless/hostap/hostap_info.c      |   17 ++-
 drivers/net/wireless/hostap/hostap_ioctl.c     |   15 +-
 drivers/net/wireless/hostap/hostap_main.c      |   30 ++--
 drivers/net/wireless/hostap/hostap_proc.c      |   15 +-
 drivers/net/wireless/ipw2100.c                 |   48 +++---
 drivers/net/wireless/ipw2200.c                 |  207 +++++++++++++-----------
 drivers/net/wireless/libertas/assoc.c          |   19 ++-
 drivers/net/wireless/libertas/cmdresp.c        |    5 +-
 drivers/net/wireless/libertas/debugfs.c        |    5 +-
 drivers/net/wireless/libertas/join.c           |   16 ++-
 drivers/net/wireless/libertas/main.c           |   12 +-
 drivers/net/wireless/libertas/scan.c           |   14 +-
 drivers/net/wireless/libertas/wext.c           |    5 +-
 drivers/net/wireless/netwave_cs.c              |   14 +-
 drivers/net/wireless/orinoco.c                 |    7 +-
 drivers/net/wireless/prism54/isl_ioctl.c       |   50 ++----
 drivers/net/wireless/ray_cs.c                  |   13 +-
 drivers/net/wireless/rtl8187_dev.c             |    5 +-
 drivers/net/wireless/wavelan.c                 |   53 +++----
 drivers/net/wireless/wavelan_cs.c              |   54 +++----
 drivers/net/wireless/wl3501_cs.c               |   22 ++--
 drivers/net/wireless/zd1211rw/zd_chip.c        |    3 +-
 drivers/net/wireless/zd1211rw/zd_mac.c         |    8 +-
 drivers/net/yellowfin.c                        |   19 +--
 drivers/net/znet.c                             |   11 +-
 drivers/net/zorro8390.c                        |   15 +-
 include/linux/if_ether.h                       |    7 +
 include/net/ieee80211.h                        |    5 -
 include/net/mac80211.h                         |    4 -
 net/802/tr.c                                   |   28 ++--
 net/appletalk/aarp.c                           |    9 +-
 net/atm/br2684.c                               |   16 +--
 net/atm/lec.c                                  |   29 ++--
 net/core/netpoll.c                             |   12 +-
 net/core/pktgen.c                              |   17 +--
 net/ethernet/eth.c                             |    8 +
 net/ieee80211/ieee80211_crypt_ccmp.c           |   27 ++--
 net/ieee80211/ieee80211_crypt_tkip.c           |   31 ++--
 net/ieee80211/ieee80211_rx.c                   |   59 ++++---
 net/ieee80211/ieee80211_wx.c                   |    5 +-
 net/ieee80211/softmac/ieee80211softmac_assoc.c |    4 +-
 net/ieee80211/softmac/ieee80211softmac_auth.c  |   35 +++--
 net/ieee80211/softmac/ieee80211softmac_wx.c    |    5 +-
 net/irda/irlan/irlan_client.c                  |    6 +-
 net/llc/llc_proc.c                             |   12 +-
 net/mac80211/debugfs_key.c                     |    3 +-
 net/mac80211/debugfs_netdev.c                  |    3 +-
 net/mac80211/debugfs_sta.c                     |    6 +-
 net/mac80211/event.c                           |    5 +-
 net/mac80211/ieee80211.c                       |    5 +-
 net/mac80211/ieee80211_ioctl.c                 |    5 +-
 net/mac80211/ieee80211_sta.c                   |  180 ++++++++++++---------
 net/mac80211/key.c                             |   10 +-
 net/mac80211/rc80211_simple.c                  |    5 +-
 net/mac80211/rx.c                              |  102 +++++++------
 net/mac80211/sta_info.c                        |   13 +-
 net/mac80211/tkip.c                            |   10 +-
 net/mac80211/tx.c                              |   32 ++--
 net/mac80211/wpa.c                             |   19 ++-
 net/tipc/eth_media.c                           |    4 +-
 215 files changed, 1700 insertions(+), 1847 deletions(-)



