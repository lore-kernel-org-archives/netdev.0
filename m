From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH net-next 0/3] cxgb4: add FCoE DDP and RSS
Date: Fri, 27 Mar 2015 20:29:36 +0530
Message-ID: <cover.1427467737.git.varun@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25302 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752949AbbC0O7w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 10:59:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables RSS for FCoE frames and adds
DDP support for FCoE target.

Varun Prakash (3):
  cxgb4: add structure and macro definitions for FCoE DDP
  cxgb4: add DDP support for FCoE target
  cxgb4: enable RSS for FCoE frames

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c |  605 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h |   54 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   47 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    7 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  328 ++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h      |   29 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   67 +++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    8 +
 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h     |   90 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h  |    3 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   11 +-
 13 files changed, 1243 insertions(+), 8 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h
