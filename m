From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: [PATCH net-next v3 0/2] Adding support for Cavium ThunderX network controller
Date: Fri, 15 May 2015 20:36:37 -0700
Message-ID: <1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com>
Cc: linux-kernel@vger.kernel.org, David Daney <david.daney@cavium.com>,
	Aleksey Makarov <aleksey.makarov@auriga.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nn-mx.auriga.ru ([81.19.133.66]:40645 "EHLO nn-mx.auriga.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992586AbbEPDmn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 May 2015 23:42:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for the Cavium ThunderX network controller.

changes in v3:
 * code cleanup
 * issues discovered by reviewers were addressed

changes in v2:
 * non-generic module parameters removed
 * ethtool support added (nicvf_set_rxnfc())

v2: https://lkml.kernel.org/g/<1415596445-10061-1-git-send-email-rric@kernel.org>
v1: https://lkml.kernel.org/g/<20141030165434.GW20170@rric.localhost>

Aleksey Makarov (1):
  pci: Add Cavium PCI vendor id

Sunil Goutham (1):
  net: Adding support for Cavium ThunderX network controller

 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/cavium/Kconfig                |   40 +
 drivers/net/ethernet/cavium/Makefile               |    5 +
 drivers/net/ethernet/cavium/thunder/Makefile       |   11 +
 drivers/net/ethernet/cavium/thunder/nic.h          |  439 ++++++
 drivers/net/ethernet/cavium/thunder/nic_main.c     |  927 +++++++++++++
 drivers/net/ethernet/cavium/thunder/nic_reg.h      |  214 +++
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |  625 +++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 1337 ++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 1416 ++++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  378 ++++++
 drivers/net/ethernet/cavium/thunder/q_struct.h     |  702 ++++++++++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  |  999 ++++++++++++++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |  224 ++++
 include/linux/pci_ids.h                            |    2 +
 17 files changed, 7328 insertions(+)
 create mode 100644 drivers/net/ethernet/cavium/Kconfig
 create mode 100644 drivers/net/ethernet/cavium/Makefile
 create mode 100644 drivers/net/ethernet/cavium/thunder/Makefile
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic_main.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nic_reg.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_ethtool.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_main.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_queues.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/nicvf_queues.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/q_struct.h
 create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_bgx.c
 create mode 100644 drivers/net/ethernet/cavium/thunder/thunder_bgx.h

-- 
2.4.0
