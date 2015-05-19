From: Aleksey Makarov <aleksey.makarov@auriga.com>
Subject: [PATCH net-next v4 0/2] Adding support for Cavium ThunderX network controller
Date: Mon, 18 May 2015 18:59:13 -0700
Message-ID: <1432000757-28700-1-git-send-email-aleksey.makarov@auriga.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	David Daney <david.daney@cavium.com>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@auriga.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patchset adds support for the Cavium ThunderX network controller.

changes in v4:
 * the patch "pci: Add Cavium PCI vendor id" was attributed correctly
 * a note that Cavium id is used in many drivers was added
 * the license comments now match MODULE_LICENSE
 * a comment explaining usage of writeq_relaxed()/readq_relaxed() was added

changes in v3:
 * code cleanup
 * issues discovered by reviewers were addressed

changes in v2:
 * non-generic module parameters removed
 * ethtool support added (nicvf_set_rxnfc())

v3: https://lkml.kernel.org/g/<1431747401-20847-1-git-send-email-aleksey.makarov@auriga.com>
v2: https://lkml.kernel.org/g/<1415596445-10061-1-git-send-email-rric@kernel.org>
v1: https://lkml.kernel.org/g/<20141030165434.GW20170@rric.localhost>

Sunil Goutham (2):
  pci: Add Cavium PCI vendor id
  net: Adding support for Cavium ThunderX network controller

 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/cavium/Kconfig                |   40 +
 drivers/net/ethernet/cavium/Makefile               |    5 +
 drivers/net/ethernet/cavium/thunder/Makefile       |   11 +
 drivers/net/ethernet/cavium/thunder/nic.h          |  438 ++++++
 drivers/net/ethernet/cavium/thunder/nic_main.c     |  939 +++++++++++++
 drivers/net/ethernet/cavium/thunder/nic_reg.h      |  213 +++
 .../net/ethernet/cavium/thunder/nicvf_ethtool.c    |  624 +++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_main.c   | 1345 +++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 1415 ++++++++++++++++++++
 drivers/net/ethernet/cavium/thunder/nicvf_queues.h |  377 ++++++
 drivers/net/ethernet/cavium/thunder/q_struct.h     |  701 ++++++++++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.c  | 1007 ++++++++++++++
 drivers/net/ethernet/cavium/thunder/thunder_bgx.h  |  223 +++
 include/linux/pci_ids.h                            |    2 +
 17 files changed, 7349 insertions(+)
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
