From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH 0/2] Netronome NFP4000/NFP6000 NIC VF driver
Date: Fri, 23 Oct 2015 19:58:09 +0100
Message-ID: <1445626691-19819-1-git-send-email-jakub.kicinski@netronome.com>
Cc: netdev@vger.kernel.org, rolf.neugebauer@netronome.com,
	jason.mcmullan@netronome.com, simon.horman@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35949 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbbJWS6R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2015 14:58:17 -0400
Received: by wicfx6 with SMTP id fx6so43396247wic.1
        for <netdev@vger.kernel.org>; Fri, 23 Oct 2015 11:58:16 -0700 (PDT)
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
 drivers/net/ethernet/netronome/Kconfig             |   33 +
 drivers/net/ethernet/netronome/Makefile            |    5 +
 drivers/net/ethernet/netronome/nfp/Makefile        |    8 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  744 ++++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 2525 ++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  318 +++
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |  235 ++
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  704 ++++++
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  404 ++++
 include/linux/pci_ids.h                            |    2 +
 13 files changed, 4987 insertions(+)
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
