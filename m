From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH 0/3] FCoE support in cxgb4 driver
Date: Tue, 24 Mar 2015 19:14:44 +0530
Message-ID: <cover.1427199268.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com, leedom@chelsio.com,
	anish@chelsio.com, hariprasad@chelsio.com, praveenm@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:25954 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752115AbbCXNqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:46:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables FCoE support in cxgb4 driver, it enables
FCOE_CRC and FCOE_MTU net device features.

This series is created against net-next tree.

Thanks

Varun Prakash (3):
  cxgb4: add cxgb4_fcoe.h and macro definitions for FCoE
  cxgb4: add cxgb4_fcoe.c for FCoE
  cxgb4: update Kconfig and Makefile for FCoE support

 drivers/net/ethernet/chelsio/Kconfig            |   11 ++
 drivers/net/ethernet/chelsio/cxgb4/Makefile     |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    7 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c |  122 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h |   57 +++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    8 ++
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   74 +++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   25 +++++
 8 files changed, 302 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h
