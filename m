From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/2] nfp: SR-IOV ndos support
Date: Thu, 24 Aug 2017 21:31:48 -0700
Message-ID: <20170825043150.375-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:35042 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdHYEcf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 00:32:35 -0400
Received: by mail-pg0-f49.google.com with SMTP id 63so8580905pgc.2
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 21:32:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This set adds basic SR-IOV including setting/getting VF MAC addresses,
VLANs, link state and spoofcheck settings.  It is wired up for both
vNICs and representors (note: ip link will not report VF settings on
VF/PF representors because they are not linked to the PF PCI device).

Pablo and team add the basic implementation, Simon and Dirk follow
up with the representor plumbing.

Pablo Cascón (1):
  nfp: add basic SR-IOV ndo functions

Simon Horman (1):
  nfp: add basic SR-IOV ndo functions to representors

 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_main.h      |   4 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   6 +
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  20 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  |   6 +
 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c | 243 +++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.h |  86 ++++++++
 drivers/net/ethernet/netronome/nfp/nic/main.c      |  12 +
 9 files changed, 378 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.c
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfp_net_sriov.h

-- 
2.11.0
