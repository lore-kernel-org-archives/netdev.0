From: Jeff Garzik <jgarzik@pobox.com>
Subject: netdev-2.6 queue updated
Date: Thu, 27 Jan 2005 19:00:32 -0500
Message-ID: <41F980A0.8020905@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040707010005060807000400"
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@osdl.org>,
        Jouni Malinen <jkmaline@cc.hut.fi>
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040707010005060807000400
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

The attached changelog describes what I just pushed out to BitKeeper 
(and what should be appearing in the next -mm release from Andrew).

Note to BK users:  please re-clone netdev-2.6, don't just 'bk pull'.

Most of this is simply stuff that is "hanging out for a while" in 
netdev-2.6 while it -- hopefully -- gets testing and review.  All of 
these changes are bound for upstream eventually.

Note on wireless:  HostAP and Vladmir's effort to make 802.11 a "real" 
Linux network protocol both seem to have stagnated a bit.  I'm still 
hoping that
* Intel will appear with a patch that merges their drivers
* some magical engineering force will start using the HostAP code as 
common library code in other drivers (notably Intel)
* Vladmir or someone will continue Vladmir's work to integrate wireless 
more closely with the Linux network stack

	Jeff



--------------040707010005060807000400
Content-Type: text/plain;
 name="changelog.txt"
Content-Disposition: inline;
 filename="changelog.txt"
Content-Transfer-Encoding: quoted-printable
X-MIME-Autoconverted: from 8bit to quoted-printable by oss.sgi.com id j0S01bjP008860

BK users:

	bk pull bk://gkernel.bkbits.net/netdev-2.6

This will update the following files:

 Documentation/networking/ixgb.txt               |    9=20
 MAINTAINERS                                     |    7=20
 drivers/net/3c503.c                             |   67=20
 drivers/net/3c515.c                             |   32=20
 drivers/net/8139cp.c                            |  100=20
 drivers/net/8139too.c                           |  291 -
 drivers/net/Kconfig                             |   12=20
 drivers/net/Makefile                            |    1=20
 drivers/net/arcnet/arc-rawmode.c                |    4=20
 drivers/net/arcnet/arc-rimi.c                   |   14=20
 drivers/net/arcnet/arcnet.c                     |   30=20
 drivers/net/arcnet/com20020.c                   |    6=20
 drivers/net/arcnet/com90io.c                    |    4=20
 drivers/net/arcnet/com90xx.c                    |    8=20
 drivers/net/arcnet/rfc1051.c                    |    8=20
 drivers/net/arcnet/rfc1201.c                    |   12=20
 drivers/net/b44.h                               |   14=20
 drivers/net/cs89x0.c                            |    4=20
 drivers/net/es3210.c                            |   32=20
 drivers/net/ewrk3.c                             |   87=20
 drivers/net/fealnx.c                            |  275 -
 drivers/net/ibmlana.c                           |   99=20
 drivers/net/ibmlana.h                           |    1=20
 drivers/net/irda/act200l-sir.c                  |    3=20
 drivers/net/irda/irtty-sir.c                    |    4=20
 drivers/net/irda/ma600-sir.c                    |   12=20
 drivers/net/irda/sir_dev.c                      |    4=20
 drivers/net/irda/tekram-sir.c                   |    3=20
 drivers/net/mv643xx_eth.c                       | 2398 +++++-----
 drivers/net/mv643xx_eth.h                       |  603 --
 drivers/net/ni65.c                              |    3=20
 drivers/net/ns83820.c                           |    3=20
 drivers/net/pcmcia/ibmtr_cs.c                   |    7=20
 drivers/net/pcmcia/xirc2ps_cs.c                 |   23=20
 drivers/net/pcnet32.c                           |   47=20
 drivers/net/sis900.c                            |  195=20
 drivers/net/sk_mca.c                            |  126=20
 drivers/net/sk_mca.h                            |   19=20
 drivers/net/skge.c                              | 3334 ++++++++++++++
 drivers/net/skge.h                              | 3005 ++++++++++++
 drivers/net/smc-mca.c                           |   37=20
 drivers/net/smc-ultra.c                         |   34=20
 drivers/net/smc-ultra32.c                       |   30=20
 drivers/net/smc91x.c                            |   37=20
 drivers/net/smc91x.h                            |   20=20
 drivers/net/tg3.h                               |   14=20
 drivers/net/tokenring/ibmtr.c                   |  158=20
 drivers/net/typhoon-firmware.h                  | 5568 ++++++++++-------=
-------
 drivers/net/typhoon.c                           |  244 -
 drivers/net/wan/cosa.c                          |    7=20
 drivers/net/wan/dscc4.c                         |  117=20
 drivers/net/wd.c                                |   36=20
 drivers/net/wireless/Kconfig                    |    2=20
 drivers/net/wireless/Makefile                   |    2=20
 drivers/net/wireless/airo.c                     |   25=20
 drivers/net/wireless/airport.c                  |    5=20
 drivers/net/wireless/arlan.h                    |    4=20
 drivers/net/wireless/atmel_cs.c                 |    3=20
 drivers/net/wireless/hermes.c                   |   43=20
 drivers/net/wireless/hermes.h                   |   62=20
 drivers/net/wireless/hostap/Kconfig             |  104=20
 drivers/net/wireless/hostap/Makefile            |    8=20
 drivers/net/wireless/hostap/hostap.c            | 1205 +++++
 drivers/net/wireless/hostap/hostap.h            |   57=20
 drivers/net/wireless/hostap/hostap_80211.h      |  107=20
 drivers/net/wireless/hostap/hostap_80211_rx.c   | 1080 ++++
 drivers/net/wireless/hostap/hostap_80211_tx.c   |  522 ++
 drivers/net/wireless/hostap/hostap_ap.c         | 3259 ++++++++++++++
 drivers/net/wireless/hostap/hostap_ap.h         |  272 +
 drivers/net/wireless/hostap/hostap_common.h     |  556 ++
 drivers/net/wireless/hostap/hostap_config.h     |   86=20
 drivers/net/wireless/hostap/hostap_crypt.c      |  167=20
 drivers/net/wireless/hostap/hostap_crypt.h      |   50=20
 drivers/net/wireless/hostap/hostap_crypt_ccmp.c |  486 ++
 drivers/net/wireless/hostap/hostap_crypt_tkip.c |  696 +++
 drivers/net/wireless/hostap/hostap_crypt_wep.c  |  281 +
 drivers/net/wireless/hostap/hostap_cs.c         |  785 +++
 drivers/net/wireless/hostap/hostap_download.c   |  761 +++
 drivers/net/wireless/hostap/hostap_hw.c         | 3607 +++++++++++++++
 drivers/net/wireless/hostap/hostap_info.c       |  469 ++
 drivers/net/wireless/hostap/hostap_ioctl.c      | 3624 +++++++++++++++
 drivers/net/wireless/hostap/hostap_pci.c        |  452 +
 drivers/net/wireless/hostap/hostap_plx.c        |  611 ++
 drivers/net/wireless/hostap/hostap_proc.c       |  466 ++
 drivers/net/wireless/hostap/hostap_wlan.h       | 1071 ++++
 drivers/net/wireless/orinoco_cs.c               |   10=20
 drivers/net/wireless/orinoco_pci.c              |    7=20
 drivers/net/wireless/orinoco_plx.c              |   82=20
 drivers/net/wireless/orinoco_tmd.c              |   51=20
 drivers/net/wireless/prism54/isl_ioctl.c        |    2=20
 include/linux/ibmtr.h                           |   15=20
 include/linux/mii.h                             |    4=20
 include/linux/mv643xx.h                         |  434 +
 include/linux/pci_ids.h                         |    8=20
 94 files changed, 32802 insertions(+), 5947 deletions(-)

through these ChangeSets:

<dfarnsworth:mvista.com>:
  o Big rename
  o Rename MV_READ =3D> mv_read and MV_WRITE =3D> mv_write
  o Additional whitespace cleanups, mostly changing spaces to tabs in com=
ments
  o Run mv643xx_eth.[ch] through scripts/Lindent
  o Add a function to detect at runtime whether a PHY is attached to the =
specified port, and use it to cause the probe routine to fail when there =
is no PHY.
  o This one liner removes a spurious left paren fixing an obvious syntax=
 error in the #ifndef MV64340_NAPI case
  o Add support for PHYs/boards that don't support autonegotiation
  o With this patch, the driver now calls netif_carrier_off/netif_carrier=
_on
  o This patch cleans up the handling of receive skb sizing

<philipp.gortan:tttech.com>:
  o [netdrvr 8139cp] add PCI ID

Alexander Viro:
  o 3c503 (iomem + isa-ectomy)
  o ibmlana part 2 (iomem annotations and isa-ectomy)
  o ibmlana part 1 (netdev_priv())
  o sk_mca - iomem and isa-ectomy
  o sk_mca - netdev_priv()
  o ibmtr 2/2: ibmtr annotations - the rest
  o ibmtr 1/2: iomem annotations - trivial part
  o es3210 iomem annotions and isa-ectomy
  o ewrk3 iomem annotations + isa-ectomy
  o wd iomem annotations + isa-ectomy
  o smc-ultra32 iomem annotations + isa-ectomy
  o smc-ultra iomem annotations + isa-ectomy
  o smc-mca iomem annotations and isa-ectomy
  o fealnx iomem annotations, switch to io{read,write}
  o wireless iomem annotations and fixes, switch to io{read,write}

Dale Farnsworth:
  o This patch simplifies the mv64340_eth_set_rx_mode function without ch=
anging its behavior.
  o This patch makes the use of the MV64340_RX_QUEUE_FILL_ON_TASK config =
macro more consistent, though the macro remains undefined, since the feat=
ure still does not work properly.
  o This patch adds support for passing additional parameters via the pla=
tform_device interface.  These additional parameters are:
  o This patch adds device driver model support to the mv643xx_eth driver
  o This patch replaces the use of the pci_map_* functions with the corre=
sponding dma_map_* functions.
  o This patch fixes the code that enables hardware checksum generation
  o This patch removes spin delays (count to 1000000, ugh) and instead wa=
its with udelay or msleep for hardware flags to change.
  o This patch removes code that is redundant or useless

Daniele Venzano:
  o sis900: chiprev i/o cleanups
  o sis900: debugging output update
  o sis900 printk audit
  o sis900: version bump; remove broken URL
  o sis900: add infrastructure needed for standard netif messages

David Dillow:
  o Bump version and release date
  o Version 03.001.008 of the Typhoon firmware, courtesy of 3Com
  o Fixup the version reporting to match 3Com
  o Use module_param() and add descriptions
  o Teach typhoon to use port IO on machines that need it. It will attemp=
t to use MMIO, but if that fails (or the user asks), it will fallback to =
port IO.
  o Enable bus mastering before saving our state, or we'll only be able t=
o load the modules one time.

David T. Hollis:
  o Move MII-related constants from b44/tg3 drivers to linux/mii.h

Domen Puncer:
  o net/ewrk3: replace schedule_timeout() with msleep_interruptible()
  o net/tekram-sir: replace schedule_timeout() with msleep()
  o net/ns83820: replace schedule_timeout() with msleep()
  o net/ni65: replace schedule_timeout() with msleep()
  o net/sir_dev: replace schedule_timeout() with msleep()
  o net/xirc2ps_cs: replace Wait() with msleep()
  o net/ma600-sir: replace schedule_timeout() with msleep()
  o net/irtty-sir: replace schedule_timeout() with msleep()
  o net/act2001-sir: replace schedule_timeout() with msleep()
  o arcnet: remove casts

Don Fry:
  o pcnet32: 79c976 with fiber optic fix

Felipe Damasio:
  o 8139cp net driver: add MODULE_VERSION

Fran=E7ois Romieu:
  o dscc4: removal of unneeded variable
  o dscc4: removal of unneeded casts
  o dscc4: error status checking and pci janitoring
  o dscc4: code factorisation
  o dscc4: use of uncompletely initialized struct
  o 8139cp: SG support fixes

Ganesh Venkatesan:
  o ixgb: Documentation/networking/ixgb.txt

Ian Campbell:
  o smc91x: power down PHY on suspend

Jeff Garzik:
  o [wireless hostap] update for new pci_save_state()
  o [netdrvr 8139cp] TSO support

Joshua Kwan:
  o hostap: fix Kconfig typos and missing select CRYPTO

Jouni Malinen:
  o Host AP: Replaced MODULE_PARM with module_param*
  o Host AP: Replaced direct dev->priv references with netdev_priv(dev)
  o Host AP: Updated to use Linux wireless extensions v17
  o Host AP: pci_register_driver() return value changes
  o Host AP: Fix netif_carrier_off() in non-client modes
  o Host AP: Fix PRISM2_IO_DEBUG
  o Host AP: Use void __iomem * with {read,write}{b,w}
  o Host AP: Fix card enabling after firmware download
  o Host AP: Do not bridge packets to unauthorized ports
  o Host AP: Fix compilation with PRISM2_NO_STATION_MODES defined
  o Host AP: Prevent STAs from associating using AP address
  o Host AP: Fix hw address changing for wifi# interface
  o Host AP: Remove ioctl debug messages
  o Host AP: Ignore (Re)AssocResp messages silently
  o Host AP: Fix interface packet counters
  o Host AP: Disable EAPOL TX/RX debug messages
  o fix hostap crypto bugs
  o Add HostAP wireless driver

JustMan:
  o atmel_cs: Add support LG LW2100N WLAN PCMCIA card

Nishanth Aravamudan:
  o net/cosa: replace schedule_timeout() with msleep()
  o net/airo: replace schedule_timeout() with msleep()/ssleep()
  o net/cs89x0: replace schedule_timeout() with msleep()

Pekka Enberg:
  o 8139too: use iomap for pio/mmio

Randy Dunlap:
  o prism54: use NULL for pointer
  o (v2) arlan: remove gcc warning with CONFIG_PROC_FS=3Dn

Rene Herman:
  o 8139too Interframe Gap Time

Steffen Klassert:
  o Add MODULE_VERSION to the 3c515 driver
  o Use netdev_priv in the 3c515 driver
  o 8139cp - add netpoll support

Stephen Hemminger:
  o skge driver (0.5)
  o 8139too: use netdev_priv
  o 8139cp - module_param

Thomas Gleixner:
  o rtl8139too.c: Fix missing pci_disable_dev
  o rtl8139too.c: Fix missing pci_disable_dev

Tony Lindgren:
  o Add OMAP support to smc91x Ethernet driver


--------------040707010005060807000400--
