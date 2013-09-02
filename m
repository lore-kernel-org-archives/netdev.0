From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 0/5] cnic: Remove duplicate bnx2x definitions
Date: Mon, 2 Sep 2013 11:42:27 -0700
Message-ID: <1378147352-9076-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2696 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755806Ab3IBSWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 14:22:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adapt the code to use existing macros and struct fields in bnx2x.h to
avoid duplication.

Michael Chan (5):
  cnic: Use CHIP_NUM macros from bnx2x.h
  cnic: Redefine BNX2X_HW_CID using existing bnx2x macros
  cnic: Eliminate CNIC_PORT macro and port_mode in local struct.
  cnic: Eliminate local copy of pfid.
  cnic: Update version to 2.5.18.

 drivers/net/ethernet/broadcom/cnic.c    |  104 ++++++++++++++++--------------
 drivers/net/ethernet/broadcom/cnic.h    |   67 +++-----------------
 drivers/net/ethernet/broadcom/cnic_if.h |    4 +-
 3 files changed, 67 insertions(+), 108 deletions(-)
