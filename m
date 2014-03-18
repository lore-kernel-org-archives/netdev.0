From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 0/3] cnic bug fixes for net-next
Date: Mon, 17 Mar 2014 19:19:05 -0800
Message-ID: <1395112748-21965-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <eddie.wai@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:51312 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753479AbaCRCAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 22:00:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan (3):
  cnic: Use proper ulp_ops for per device operations.
  cnic,bnx2i,bnx2fc: Fix inconsistent use of page size
  cnic: Update version to 2.5.20 and copyright year.

 drivers/net/ethernet/broadcom/cnic.c      |  111 +++++++++++++++--------------
 drivers/net/ethernet/broadcom/cnic.h      |    2 +-
 drivers/net/ethernet/broadcom/cnic_defs.h |    2 +-
 drivers/net/ethernet/broadcom/cnic_if.h   |   16 ++++-
 drivers/scsi/bnx2fc/bnx2fc_io.c           |   16 ++--
 drivers/scsi/bnx2fc/bnx2fc_tgt.c          |   38 ++++++-----
 drivers/scsi/bnx2i/bnx2i_hwi.c            |   52 +++++++-------
 drivers/scsi/bnx2i/bnx2i_iscsi.c          |   23 +++---
 8 files changed, 138 insertions(+), 122 deletions(-)
