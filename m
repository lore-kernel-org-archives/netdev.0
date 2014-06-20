From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH v2 net-next 0/5] cxgb4 : Add DCBx support to Chelsio cxgb4 driver
Date: Thu, 19 Jun 2014 21:37:10 -0700
Message-ID: <1403239035-10771-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:36092
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933085AbaFTEh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 00:37:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2 : move inclusion of struct port_dcb_info to the same patch as where it is defined.

Hi,
    This patchset adds support for DCBx via dcbnl_ops to the cxgb4 driver. This should enable cxgb4 to work with open-lldp and the like. The last patch only updates copyright year.

Applies on top of commit id e0f802fbcaa3bffe4728e37a8fa1279b5d554173 of the net-next tree.

checkpatch.pl --strict currently generates two false positives for 0002-cxgb4-Add-DCBx-support-codebase-and-dcbnl_ops.patch, fix for this is already in the -mm tree.
Thanks,
Anish

Signed-off-by: Anish Bhatt <anish@chelsio.com>
--
Anish Bhatt (5):
  cxgb4 : Update fw interface file for DCBx support. Adds all the
    required fields to fw interface to communicate DCBx info
  cxgb4 : Add DCBx support codebase and dcbnl_ops
  cxgb4 : Integrate DCBx support into cxgb4 module. Register dbcnl_ops
    to give access to DCBx functions
  cxgb4 : Makefile & Kconfig changes for DCBx support
  cxgb4 : Update copyright year on all cxgb4 files

 drivers/net/ethernet/chelsio/Kconfig            |  11 +
 drivers/net/ethernet/chelsio/cxgb4/Makefile     |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  13 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c  | 980 ++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h  | 141 ++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 201 ++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.c        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/l2t.h        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  78 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h      |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  97 ++-
 15 files changed, 1492 insertions(+), 44 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.h

-- 
2.0.0
