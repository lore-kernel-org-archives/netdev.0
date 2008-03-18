From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates for .26
Date: Tue, 18 Mar 2008 03:59:02 -0400
Message-ID: <20080318075902.GA18010@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39199 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751828AbYCRH7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2008 03:59:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Just sent this upstream to davem for 2.6.26...  snipped the patch I
usually post along with a git push, due to mailing list restrictions.

Please pull from 'upstream-net26' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-net26

to receive the following updates:

 Documentation/feature-removal-schedule.txt         |   10 -
 arch/s390/defconfig                                |    8 +-
 drivers/net/8390.c                                 |    6 +-
 drivers/net/Kconfig                                |   87 -
 drivers/net/Makefile                               |    3 +-
 drivers/net/appletalk/cops.c                       |    6 +-
 drivers/net/arcnet/com20020.c                      |    7 +-
 drivers/net/at1700.c                               |    7 +-
 drivers/net/atarilance.c                           |    7 +-
 drivers/net/atl1/Makefile                          |    2 -
 drivers/net/atl1/atl1.h                            |  286 -
 drivers/net/atl1/atl1_ethtool.c                    |  505 --
 drivers/net/atl1/atl1_hw.c                         |  720 --
 drivers/net/atl1/atl1_hw.h                         |  946 ---
 drivers/net/atl1/atl1_param.c                      |  203 -
 drivers/net/atlx/Makefile                          |    1 +
 drivers/net/{atl1/atl1_main.c => atlx/atl1.c}      | 2118 ++++--
 drivers/net/atlx/atl1.h                            |  796 ++
 drivers/net/atlx/atlx.c                            |  433 +
 drivers/net/atlx/atlx.h                            |  506 ++
 drivers/net/ixgbe/ixgbe.h                          |   87 +-
 drivers/net/ixgbe/ixgbe_ethtool.c                  |   39 +-
 drivers/net/ixgbe/ixgbe_main.c                     | 1520 +++-
 drivers/net/s2io.c                                 |  444 +-
 drivers/net/s2io.h                                 |   50 +-
 drivers/net/sk98lin/Makefile                       |   87 -
 drivers/net/sk98lin/h/lm80.h                       |  179 -
 drivers/net/sk98lin/h/skaddr.h                     |  285 -
 drivers/net/sk98lin/h/skcsum.h                     |  213 -
 drivers/net/sk98lin/h/skdebug.h                    |   74 -
 drivers/net/sk98lin/h/skdrv1st.h                   |  188 -
 drivers/net/sk98lin/h/skdrv2nd.h                   |  447 -
 drivers/net/sk98lin/h/skerror.h                    |   55 -
 drivers/net/sk98lin/h/skgedrv.h                    |   51 -
 drivers/net/sk98lin/h/skgehw.h                     | 2126 -----
 drivers/net/sk98lin/h/skgehwt.h                    |   48 -
 drivers/net/sk98lin/h/skgei2c.h                    |  210 -
 drivers/net/sk98lin/h/skgeinit.h                   |  797 --
 drivers/net/sk98lin/h/skgepnm2.h                   |  334 -
 drivers/net/sk98lin/h/skgepnmi.h                   |  962 ---
 drivers/net/sk98lin/h/skgesirq.h                   |  110 -
 drivers/net/sk98lin/h/ski2c.h                      |  174 -
 drivers/net/sk98lin/h/skqueue.h                    |   94 -
 drivers/net/sk98lin/h/skrlmt.h                     |  438 -
 drivers/net/sk98lin/h/sktimer.h                    |   63 -
 drivers/net/sk98lin/h/sktypes.h                    |   69 -
 drivers/net/sk98lin/h/skversion.h                  |   38 -
 drivers/net/sk98lin/h/skvpd.h                      |  248 -
 drivers/net/sk98lin/h/xmac_ii.h                    | 1579 ----
 drivers/net/sk98lin/skaddr.c                       | 1788 ----
 drivers/net/sk98lin/skdim.c                        |  742 --
 drivers/net/sk98lin/skethtool.c                    |  627 --
 drivers/net/sk98lin/skge.c                         | 5218 ------------
 drivers/net/sk98lin/skgehwt.c                      |  171 -
 drivers/net/sk98lin/skgeinit.c                     | 2005 -----
 drivers/net/sk98lin/skgemib.c                      | 1075 ---
 drivers/net/sk98lin/skgepnmi.c                     | 8198 ------------------
 drivers/net/sk98lin/skgesirq.c                     | 2229 -----
 drivers/net/sk98lin/ski2c.c                        | 1296 ---
 drivers/net/sk98lin/sklm80.c                       |  141 -
 drivers/net/sk98lin/skqueue.c                      |  179 -
 drivers/net/sk98lin/skrlmt.c                       | 3257 -------
 drivers/net/sk98lin/sktimer.c                      |  250 -
 drivers/net/sk98lin/skvpd.c                        | 1091 ---
 drivers/net/sk98lin/skxmac2.c                      | 4160 ---------
 drivers/net/smc91x.c                               |  335 +-
 drivers/net/smc91x.h                               |  331 +-
 drivers/net/tulip/Kconfig                          |   15 +-
 drivers/net/tulip/Makefile                         |    1 -
 drivers/net/tulip/xircom_tulip_cb.c                | 1726 ----
 drivers/s390/net/Kconfig                           |   84 +-
 drivers/s390/net/Makefile                          |   12 +-
 drivers/s390/net/ctcdbug.c                         |   80 -
 drivers/s390/net/ctcdbug.h                         |  125 -
 drivers/s390/net/ctcm_dbug.c                       |   67 +
 drivers/s390/net/ctcm_dbug.h                       |  158 +
 drivers/s390/net/ctcm_fsms.c                       | 2347 +++++
 drivers/s390/net/ctcm_fsms.h                       |  359 +
 drivers/s390/net/ctcm_main.c                       | 1772 ++++
 drivers/s390/net/ctcm_main.h                       |  287 +
 drivers/s390/net/ctcm_mpc.c                        | 2472 ++++++
 drivers/s390/net/ctcm_mpc.h                        |  239 +
 drivers/s390/net/ctcm_sysfs.c                      |  210 +
 drivers/s390/net/ctcmain.c                         | 3062 -------
 drivers/s390/net/ctcmain.h                         |  270 -
 drivers/s390/net/{qeth.h => qeth_core.h}           |  811 +--
 drivers/s390/net/qeth_core_main.c                  | 4540 ++++++++++
 drivers/s390/net/qeth_core_mpc.c                   |  266 +
 drivers/s390/net/{qeth_mpc.h => qeth_core_mpc.h}   |  143 +-
 drivers/s390/net/{qeth_eddp.c => qeth_core_offl.c} |  287 +-
 drivers/s390/net/{qeth_eddp.h => qeth_core_offl.h} |   50 +-
 drivers/s390/net/qeth_core_sys.c                   |  651 ++
 drivers/s390/net/qeth_fs.h                         |  168 -
 drivers/s390/net/qeth_l2_main.c                    | 1242 +++
 drivers/s390/net/qeth_l3.h                         |   76 +
 drivers/s390/net/qeth_l3_main.c                    | 3388 ++++++++
 drivers/s390/net/qeth_l3_sys.c                     | 1051 +++
 drivers/s390/net/qeth_main.c                       | 8956 --------------------
 drivers/s390/net/qeth_mpc.c                        |  269 -
 drivers/s390/net/qeth_proc.c                       |  316 -
 drivers/s390/net/qeth_sys.c                        | 1858 ----
 drivers/s390/net/qeth_tso.h                        |  148 -
 include/linux/smc91x.h                             |   13 +
 103 files changed, 25085 insertions(+), 63193 deletions(-)
 delete mode 100644 drivers/net/atl1/Makefile
 delete mode 100644 drivers/net/atl1/atl1.h
 delete mode 100644 drivers/net/atl1/atl1_ethtool.c
 delete mode 100644 drivers/net/atl1/atl1_hw.c
 delete mode 100644 drivers/net/atl1/atl1_hw.h
 delete mode 100644 drivers/net/atl1/atl1_param.c
 create mode 100644 drivers/net/atlx/Makefile
 rename drivers/net/{atl1/atl1_main.c => atlx/atl1.c} (57%)
 create mode 100644 drivers/net/atlx/atl1.h
 create mode 100644 drivers/net/atlx/atlx.c
 create mode 100644 drivers/net/atlx/atlx.h
 delete mode 100644 drivers/net/sk98lin/Makefile
 delete mode 100644 drivers/net/sk98lin/h/lm80.h
 delete mode 100644 drivers/net/sk98lin/h/skaddr.h
 delete mode 100644 drivers/net/sk98lin/h/skcsum.h
 delete mode 100644 drivers/net/sk98lin/h/skdebug.h
 delete mode 100644 drivers/net/sk98lin/h/skdrv1st.h
 delete mode 100644 drivers/net/sk98lin/h/skdrv2nd.h
 delete mode 100644 drivers/net/sk98lin/h/skerror.h
 delete mode 100644 drivers/net/sk98lin/h/skgedrv.h
 delete mode 100644 drivers/net/sk98lin/h/skgehw.h
 delete mode 100644 drivers/net/sk98lin/h/skgehwt.h
 delete mode 100644 drivers/net/sk98lin/h/skgei2c.h
 delete mode 100644 drivers/net/sk98lin/h/skgeinit.h
 delete mode 100644 drivers/net/sk98lin/h/skgepnm2.h
 delete mode 100644 drivers/net/sk98lin/h/skgepnmi.h
 delete mode 100644 drivers/net/sk98lin/h/skgesirq.h
 delete mode 100644 drivers/net/sk98lin/h/ski2c.h
 delete mode 100644 drivers/net/sk98lin/h/skqueue.h
 delete mode 100644 drivers/net/sk98lin/h/skrlmt.h
 delete mode 100644 drivers/net/sk98lin/h/sktimer.h
 delete mode 100644 drivers/net/sk98lin/h/sktypes.h
 delete mode 100644 drivers/net/sk98lin/h/skversion.h
 delete mode 100644 drivers/net/sk98lin/h/skvpd.h
 delete mode 100644 drivers/net/sk98lin/h/xmac_ii.h
 delete mode 100644 drivers/net/sk98lin/skaddr.c
 delete mode 100644 drivers/net/sk98lin/skdim.c
 delete mode 100644 drivers/net/sk98lin/skethtool.c
 delete mode 100644 drivers/net/sk98lin/skge.c
 delete mode 100644 drivers/net/sk98lin/skgehwt.c
 delete mode 100644 drivers/net/sk98lin/skgeinit.c
 delete mode 100644 drivers/net/sk98lin/skgemib.c
 delete mode 100644 drivers/net/sk98lin/skgepnmi.c
 delete mode 100644 drivers/net/sk98lin/skgesirq.c
 delete mode 100644 drivers/net/sk98lin/ski2c.c
 delete mode 100644 drivers/net/sk98lin/sklm80.c
 delete mode 100644 drivers/net/sk98lin/skqueue.c
 delete mode 100644 drivers/net/sk98lin/skrlmt.c
 delete mode 100644 drivers/net/sk98lin/sktimer.c
 delete mode 100644 drivers/net/sk98lin/skvpd.c
 delete mode 100644 drivers/net/sk98lin/skxmac2.c
 delete mode 100644 drivers/net/tulip/xircom_tulip_cb.c
 delete mode 100644 drivers/s390/net/ctcdbug.c
 delete mode 100644 drivers/s390/net/ctcdbug.h
 create mode 100644 drivers/s390/net/ctcm_dbug.c
 create mode 100644 drivers/s390/net/ctcm_dbug.h
 create mode 100644 drivers/s390/net/ctcm_fsms.c
 create mode 100644 drivers/s390/net/ctcm_fsms.h
 create mode 100644 drivers/s390/net/ctcm_main.c
 create mode 100644 drivers/s390/net/ctcm_main.h
 create mode 100644 drivers/s390/net/ctcm_mpc.c
 create mode 100644 drivers/s390/net/ctcm_mpc.h
 create mode 100644 drivers/s390/net/ctcm_sysfs.c
 delete mode 100644 drivers/s390/net/ctcmain.c
 delete mode 100644 drivers/s390/net/ctcmain.h
 rename drivers/s390/net/{qeth.h => qeth_core.h} (52%)
 create mode 100644 drivers/s390/net/qeth_core_main.c
 create mode 100644 drivers/s390/net/qeth_core_mpc.c
 rename drivers/s390/net/{qeth_mpc.h => qeth_core_mpc.h} (78%)
 rename drivers/s390/net/{qeth_eddp.c => qeth_core_offl.c} (67%)
 rename drivers/s390/net/{qeth_eddp.h => qeth_core_offl.h} (55%)
 create mode 100644 drivers/s390/net/qeth_core_sys.c
 delete mode 100644 drivers/s390/net/qeth_fs.h
 create mode 100644 drivers/s390/net/qeth_l2_main.c
 create mode 100644 drivers/s390/net/qeth_l3.h
 create mode 100644 drivers/s390/net/qeth_l3_main.c
 create mode 100644 drivers/s390/net/qeth_l3_sys.c
 delete mode 100644 drivers/s390/net/qeth_main.c
 delete mode 100644 drivers/s390/net/qeth_mpc.c
 delete mode 100644 drivers/s390/net/qeth_proc.c
 delete mode 100644 drivers/s390/net/qeth_sys.c
 delete mode 100644 drivers/s390/net/qeth_tso.h
 create mode 100644 include/linux/smc91x.h

Adrian Bunk (1):
      remove the obsolete xircom_tulip_cb driver

Auke Kok (1):
      ixgbe: Increment version

Ayyappan Veeraiyan (3):
      ixgbe: Introduce MSI-X queue vector code
      ixgbe: Introduce Multiqueue TX
      ixgbe: Introduce adaptive interrupt moderation

Frank Blaschka (2):
      qeth: new qeth device driver
      qeth: remove old qeth files

Jay Cliburn (10):
      atl1: relocate atl1 driver to /drivers/net/atlx
      atl1: move common functions to atlx files
      atl1: fix broken TSO
      atl1: add ethtool register dump
      atl1: simplify tx packet descriptor
      atl1: use csum_start
      atl1: use netif_msg
      atl1: print debug info if rrd error
      atl1: make functions static
      atl1: reduce forward declarations

Jeb Cramer (1):
      ixgbe: Add optional DCA infrastructure

Jon Schindler (5):
      /drivers/net/8390.c replaced init_module&cleanup_module with module_init&module_exit
      /drivers/net/appletalk/cops.c replaced init_module&cleanup_module with module_init&module_exit
      /drivers/net/arcnet/com20020.c replaced init_module&cleanup_module with module_init&module_exit
      /drivers/net/at1700.c replaced init_module&cleanup_module with module_init&module_exit
      /drivers/net/atarilance.c replaced init_module&cleanup_module with module_init&module_exit

Magnus Damm (4):
      smc91x: pass along private data V2
      smc91x: introduce platform data flags V2
      smc91x: add insw/outsw to default config V2
      smc91x: make superh use default config V2

Peter Tiedemann (2):
      ctcm: infrastructure for replaced ctc driver
      ctc: removal of the old ctc driver

Sreenivasa Honnur (4):
      S2io: Multiqueue network device support implementation
      S2io: Multiqueue network device support - FIFO selection based on L4 ports
      S2io: Support for vlan_rx_kill_vid entry point
      S2io: Version update for multiqueue and vlan patches

Stephen Hemminger (1):
      sk98lin: remove obsolete driver

Ursula Braun (1):
      drivers/s390/net: Kconfig brush up

