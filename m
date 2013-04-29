From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH net 0/3] Bug fixes for cxgb4 and cxgb4vf
Date: Mon, 29 Apr 2013 19:34:38 +0530
Message-ID: <1367244281-23043-1-git-send-email-vipul@chelsio.com>
Cc: davem@davemloft.net, divy@chelsio.com, dm@chelsio.com,
	abhishek@chelsio.com, leedom@chelsio.com,
	swise@opengridcomputing.com, Vipul Pandya <vipul@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11073 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757596Ab3D2OK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 10:10:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

This patch series does the following:
1. Passes correct PF number during initialization of pci_device_id structure
2. Adds code in cxgb4 and cxgb4vf driver to handle CPL_SGE_EGR_UPDATE message
   encapsulated in a CPL_FW4_MSG.

We would like to request this patch series to get merged via David Miller's
'net' tree.

Thanks,
Vipul

Vipul Pandya (3):
  cxgb4: Fix pci_device_id structure initialization with correct PF
    number
  cxgb4: Support CPL_SGE_EGR_UPDATEs encapsulated in a CPL_FW4_MSG
  cxgb4vf: Support CPL_SGE_EGR_UPDATEs encapsulated in a CPL_FW4_MSG

 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 107 +++++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  11 +++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  38 +++++++-
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    |  25 +++++
 4 files changed, 140 insertions(+), 41 deletions(-)

-- 
1.8.0
