From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] new network drivers for net-next
Date: Thu, 18 Sep 2008 12:00:05 -0400
Message-ID: <20080918160005.GA24281@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:54494 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534AbYIRQAW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2008 12:00:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'new-drivers' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git new-drivers

to receive the following updates:

 Documentation/networking/LICENSE.qlge |   46 +
 MAINTAINERS                           |   20 +
 drivers/net/Kconfig                   |   39 +
 drivers/net/Makefile                  |    4 +
 drivers/net/atlx/Makefile             |    2 +
 drivers/net/atlx/atl2.c               | 3127 ++++++++++++++++++++++++++
 drivers/net/atlx/atl2.h               |  530 +++++
 drivers/net/enic/Makefile             |    5 +
 drivers/net/enic/cq_desc.h            |   79 +
 drivers/net/enic/cq_enet_desc.h       |  169 ++
 drivers/net/enic/enic.h               |  115 +
 drivers/net/enic/enic_main.c          | 1949 ++++++++++++++++
 drivers/net/enic/enic_res.c           |  370 +++
 drivers/net/enic/enic_res.h           |  151 ++
 drivers/net/enic/rq_enet_desc.h       |   60 +
 drivers/net/enic/vnic_cq.c            |   89 +
 drivers/net/enic/vnic_cq.h            |  113 +
 drivers/net/enic/vnic_dev.c           |  674 ++++++
 drivers/net/enic/vnic_dev.h           |  106 +
 drivers/net/enic/vnic_devcmd.h        |  282 +++
 drivers/net/enic/vnic_enet.h          |   47 +
 drivers/net/enic/vnic_intr.c          |   62 +
 drivers/net/enic/vnic_intr.h          |   92 +
 drivers/net/enic/vnic_nic.h           |   65 +
 drivers/net/enic/vnic_resource.h      |   63 +
 drivers/net/enic/vnic_rq.c            |  199 ++
 drivers/net/enic/vnic_rq.h            |  204 ++
 drivers/net/enic/vnic_rss.h           |   32 +
 drivers/net/enic/vnic_stats.h         |   70 +
 drivers/net/enic/vnic_wq.c            |  184 ++
 drivers/net/enic/vnic_wq.h            |  154 ++
 drivers/net/enic/wq_enet_desc.h       |   98 +
 drivers/net/jme.c                     | 3019 +++++++++++++++++++++++++
 drivers/net/jme.h                     | 1199 ++++++++++
 drivers/net/qlge/Makefile             |    7 +
 drivers/net/qlge/qlge.h               | 1593 +++++++++++++
 drivers/net/qlge/qlge_dbg.c           |  858 +++++++
 drivers/net/qlge/qlge_ethtool.c       |  415 ++++
 drivers/net/qlge/qlge_main.c          | 3954 +++++++++++++++++++++++++++++++++
 drivers/net/qlge/qlge_mpi.c           |  150 ++
 include/linux/pci_ids.h               |    3 +
 41 files changed, 20398 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/LICENSE.qlge
 create mode 100644 drivers/net/atlx/atl2.c
 create mode 100644 drivers/net/atlx/atl2.h
 create mode 100644 drivers/net/enic/Makefile
 create mode 100644 drivers/net/enic/cq_desc.h
 create mode 100644 drivers/net/enic/cq_enet_desc.h
 create mode 100644 drivers/net/enic/enic.h
 create mode 100644 drivers/net/enic/enic_main.c
 create mode 100644 drivers/net/enic/enic_res.c
 create mode 100644 drivers/net/enic/enic_res.h
 create mode 100644 drivers/net/enic/rq_enet_desc.h
 create mode 100644 drivers/net/enic/vnic_cq.c
 create mode 100644 drivers/net/enic/vnic_cq.h
 create mode 100644 drivers/net/enic/vnic_dev.c
 create mode 100644 drivers/net/enic/vnic_dev.h
 create mode 100644 drivers/net/enic/vnic_devcmd.h
 create mode 100644 drivers/net/enic/vnic_enet.h
 create mode 100644 drivers/net/enic/vnic_intr.c
 create mode 100644 drivers/net/enic/vnic_intr.h
 create mode 100644 drivers/net/enic/vnic_nic.h
 create mode 100644 drivers/net/enic/vnic_resource.h
 create mode 100644 drivers/net/enic/vnic_rq.c
 create mode 100644 drivers/net/enic/vnic_rq.h
 create mode 100644 drivers/net/enic/vnic_rss.h
 create mode 100644 drivers/net/enic/vnic_stats.h
 create mode 100644 drivers/net/enic/vnic_wq.c
 create mode 100644 drivers/net/enic/vnic_wq.h
 create mode 100644 drivers/net/enic/wq_enet_desc.h
 create mode 100644 drivers/net/jme.c
 create mode 100644 drivers/net/jme.h
 create mode 100644 drivers/net/qlge/Makefile
 create mode 100644 drivers/net/qlge/qlge.h
 create mode 100644 drivers/net/qlge/qlge_dbg.c
 create mode 100644 drivers/net/qlge/qlge_ethtool.c
 create mode 100644 drivers/net/qlge/qlge_main.c
 create mode 100644 drivers/net/qlge/qlge_mpi.c

Chris Snook (1):
      atl2: add atl2 driver

Guo-Fu Tseng (1):
      jme: JMicron Gigabit Ethernet Driver

Ron Mercer (1):
      qlge: New Qlogic 10Gb Ethernet Driver.

Scott Feldman (1):
      enic: add Cisco 10G Ethernet NIC driver

[patch snipped, for mailing list; see git for patch]
