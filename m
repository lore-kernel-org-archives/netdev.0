From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net 0/2] Fix cnic regressions
Date: Wed, 18 Sep 2013 01:50:37 -0700
Message-ID: <1379494239-5481-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2741 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959Ab3IRIaj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Sep 2013 04:30:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix regressions caused by Doorbell change and macro change.

Ariel Elior (1):
  bnx2x, cnic, bnx2i, bnx2fc: Fix bnx2i and bnx2fc regressions.
Michael Chan (1):
  cnic: Fix crash in cnic_bnx2x_service_kcq()

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |   36 ++++++++++++++++++++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++
 drivers/net/ethernet/broadcom/cnic.c             |    6 ++-
 drivers/scsi/bnx2fc/bnx2fc.h                     |    2 +-
 drivers/scsi/bnx2fc/bnx2fc_hwi.c                 |    3 +-
 drivers/scsi/bnx2i/bnx2i.h                       |    2 +-
 drivers/scsi/bnx2i/bnx2i_hwi.c                   |    3 +-
 7 files changed, 45 insertions(+), 11 deletions(-)
