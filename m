From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v3 0/2] Netronome NFP4000/NFP6000 NIC VF driver
Date: Mon, 23 Nov 2015 11:04:55 +0000
Message-ID: <1448276697-2508-1-git-send-email-jakub.kicinski@netronome.com>
References: <20151030.192701.377276134095637949.davem@davemloft.net>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35236 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309AbbKWLFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2015 06:05:06 -0500
Received: by wmuu63 with SMTP id u63so48881585wmu.0
        for <netdev@vger.kernel.org>; Mon, 23 Nov 2015 03:05:04 -0800 (PST)
In-Reply-To: <20151030.192701.377276134095637949.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for VFs of Netronome's NFP-4000 and NFP-6000
based NICs. We are currently also preparing the submission for the PF
driver, but it is not quite ready yet. The PF driver can be found on
GitHub:

https://github.com/Netronome/nfp-drv-kmods

changes since v2:

Per DaveM comment I've dropped the code which was managing the MSI-X
table from the driver side, but I still had to open code unmasking
since no appropriate core function is exported.

There were quite a few small changes to this series since v2, if anyone
is  interested in the full changelog - previous revision was based on
16ecade76a89 ("nfp_net_main: Correct some minor issues") in the GitHub
repo, this is based on HEAD.


Jakub Kicinski (2):
  pci_ids: add Netronome Systems vendor
  net: add driver for Netronome NFP4000/NFP6000 NIC VFs

 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/netronome/Kconfig             |   33 +
 drivers/net/ethernet/netronome/Makefile            |    5 +
 drivers/net/ethernet/netronome/nfp/Makefile        |    8 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  767 ++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 2472 ++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  323 +++
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  235 ++
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  640 +++++
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  385 +++
 include/linux/pci_ids.h                            |    2 +
 13 files changed, 4879 insertions(+)
 create mode 100644 drivers/net/ethernet/netronome/Kconfig
 create mode 100644 drivers/net/ethernet/netronome/Makefile
 create mode 100644 drivers/net/ethernet/netronome/nfp/Makefile
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_common.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_debugfs.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_netvf_main.c

-- 
1.9.1
