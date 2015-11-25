From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v4 0/2] Netronome NFP4000/NFP6000 NIC VF driver
Date: Wed, 25 Nov 2015 15:39:02 +0000
Message-ID: <1448465944-32294-1-git-send-email-jakub.kicinski@netronome.com>
References: <1445969758-12779-1-git-send-email-jakub.kicinski@netronome.com>
Cc: simon.horman@netronome.com, rolf.neugebauer@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34141 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751368AbbKYPjK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2015 10:39:10 -0500
Received: by wmvv187 with SMTP id v187so262812250wmv.1
        for <netdev@vger.kernel.org>; Wed, 25 Nov 2015 07:39:09 -0800 (PST)
In-Reply-To: <1445969758-12779-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for VFs of Netronome's NFP-4000 and NFP-6000
based NICs. We are currently also preparing the submission for the PF
driver, but it is not quite ready yet. The PF driver can be found on
GitHub:

https://github.com/Netronome/nfp-drv-kmods


Jakub Kicinski (2):
  pci_ids: add Netronome Systems vendor
  net: add driver for Netronome NFP4000/NFP6000 NIC VFs

 MAINTAINERS                                        |    7 +
 drivers/net/ethernet/Kconfig                       |    1 +
 drivers/net/ethernet/Makefile                      |    1 +
 drivers/net/ethernet/netronome/Kconfig             |   36 +
 drivers/net/ethernet/netronome/Makefile            |    5 +
 drivers/net/ethernet/netronome/nfp/Makefile        |    8 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  761 ++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 2449 ++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  323 +++
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  235 ++
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  640 +++++
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  385 +++
 include/linux/pci_ids.h                            |    2 +
 13 files changed, 4853 insertions(+)
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
