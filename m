From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Wed, 16 Jun 2004 21:01:57 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040617010157.GA9769@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: NetDev list <netdev@oss.sgi.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(just sent to andrew/linus)

BK users may do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 Documentation/networking/00-INDEX             |    2 
 drivers/net/3c501.c                           |    2 
 drivers/net/3c503.c                           |    6 
 drivers/net/3c505.c                           |    3 
 drivers/net/3c507.c                           |    4 
 drivers/net/3c523.c                           |    4 
 drivers/net/3c527.c                           |    4 
 drivers/net/8139too.c                         |    2 
 drivers/net/82596.c                           |    4 
 drivers/net/Kconfig                           |   85 
 drivers/net/Makefile                          |    1 
 drivers/net/ac3200.c                          |    8 
 drivers/net/acenic.c                          |  248 -
 drivers/net/acenic.h                          |    1 
 drivers/net/apne.c                            |    6 
 drivers/net/arm/Kconfig                       |   17 
 drivers/net/arm/Makefile                      |    1 
 drivers/net/arm/smc91x.c                      | 2171 +++++++++++++++++
 drivers/net/arm/smc91x.h                      |  829 ++++++
 drivers/net/at1700.c                          |    8 
 drivers/net/cs89x0.c                          |    8 
 drivers/net/defxx.c                           |    6 
 drivers/net/e2100.c                           |    6 
 drivers/net/eepro.c                           |    6 
 drivers/net/eexpress.c                        |    2 
 drivers/net/epic100.c                         |    5 
 drivers/net/es3210.c                          |    2 
 drivers/net/eth16i.c                          |   10 
 drivers/net/ewrk3.c                           |    6 
 drivers/net/fealnx.c                          |    5 
 drivers/net/fmv18x.c                          |    6 
 drivers/net/forcedeth.c                       |    3 
 drivers/net/hp-plus.c                         |    6 
 drivers/net/hp.c                              |   10 
 drivers/net/hp100.c                           |    2 
 drivers/net/ibmlana.c                         |    6 
 drivers/net/isa-skeleton.c                    |    2 
 drivers/net/jazzsonic.c                       |    4 
 drivers/net/lance.c                           |    2 
 drivers/net/lne390.c                          |   10 
 drivers/net/lp486e.c                          |    4 
 drivers/net/natsemi.c                         |    7 
 drivers/net/ne-h8300.c                        |    6 
 drivers/net/ne.c                              |    6 
 drivers/net/ne2.c                             |    8 
 drivers/net/ne2k_cbus.c                       |    6 
 drivers/net/ne3210.c                          |   10 
 drivers/net/ni52.c                            |    4 
 drivers/net/ns83820.c                         |    4 
 drivers/net/oaknet.c                          |    2 
 drivers/net/r8169.c                           |    2 
 drivers/net/smc-mca.c                         |    4 
 drivers/net/smc-ultra.c                       |    6 
 drivers/net/smc-ultra32.c                     |    4 
 drivers/net/smc9194.c                         |    8 
 drivers/net/starfire.c                        |    2 
 drivers/net/stnic.c                           |    4 
 drivers/net/sun3_82586.c                      |    4 
 drivers/net/sungem.c                          |    2 
 drivers/net/sunhme.c                          |    4 
 drivers/net/tulip/Kconfig                     |   15 
 drivers/net/tulip/winbond-840.c               |    6 
 drivers/net/via-rhine.c                       |  306 +-
 drivers/net/via-velocity.c                    | 3277 ++++++++++++++++++++++++++
 drivers/net/via-velocity.h                    | 1885 ++++++++++++++
 drivers/net/wd.c                              |    6 
 drivers/net/wireless/prism54/isl_38xx.c       |  134 -
 drivers/net/wireless/prism54/isl_38xx.h       |   10 
 drivers/net/wireless/prism54/isl_ioctl.c      |  196 -
 drivers/net/wireless/prism54/isl_ioctl.h      |    1 
 drivers/net/wireless/prism54/islpci_dev.c     |  161 +
 drivers/net/wireless/prism54/islpci_dev.h     |   22 
 drivers/net/wireless/prism54/islpci_eth.c     |   73 
 drivers/net/wireless/prism54/islpci_hotplug.c |    3 
 drivers/net/wireless/prism54/islpci_mgt.c     |  165 -
 drivers/net/wireless/prism54/islpci_mgt.h     |   11 
 drivers/net/wireless/prism54/oid_mgt.c        |   88 
 drivers/net/wireless/prism54/oid_mgt.h        |    2 
 drivers/net/wireless/prism54/prismcompat.h    |   46 
 drivers/net/yellowfin.c                       |    7 
 drivers/net/zorro8390.c                       |    6 
 81 files changed, 9142 insertions(+), 888 deletions(-)

through these ChangeSets:

 D (Alex):
  o fealnx-mac-address-and-other-issues.patch

Adrian Bunk:
  o add NAPI help texts

Alan Cox:
  o add new via-velocity gigabit ethernet driver

Andrew Morton:
  o prism94 build fix

Arthur Othieno:
  o Kill stale references to Documentation/networking/8139too.txt

Evgeniy Polyakov:
  o Typo in ethtool code in acenic driver

Herbert Xu:
  o [NETDRV #2] Use driver-specific name for resources
  o [NETDRV #1] Ifdef builtin-only probe in ISA/MCA drivers

Jeff Garzik:
  o [netdrvr acenic] remove unneeded ifdefs

Margit Schubert-While:
  o prism54: White space and indentation
  o prism54: Fix typo
  o prism54: Fix channel stats, bump version to 1.2
  o prism54: Reduce module verbosity
  o prism54: Align skb patch
  o prism54: Add likely/unlikely, KO wds completely
  o prism54: Don't allow mib reads while unconfigured
  o prism54: Fix bug 77, strengthened oid txn
  o prism54: Fix bugs 39/73
  o prism54: Fix bugs 74/75
  o prism54: Fix endian patch
  o prism54: Kernel compatibility

Roger Luethi:
  o Add rhine_power_init(): get power regs into sane state
  o Rewrite special-casing
  o Return codes for rhine_init_one
  o Nuke all pci_flags
  o Nuke default_port, references to if_port, medialock
  o Nuke HasESIPhy and related code
  o Nuke CanHaveMII and related code
  o Nuke HAS_IP_COPYSUM
  o Nuke HAS_IP_COPYSUM for net drivers

Russell King:
  o add ARM smc91x driver

Stephen Hemminger:
  o fix oops from acenic ethtool
