From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 0/3] tg3: TSO related enhancements to prevent memory allocation failure
Date: Sun, 11 May 2014 20:22:52 -0700
Message-ID: <1399864975-29070-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <prashant@broadcom.com>,
	<ivecera@redhat.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:50292 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983AbaELCCR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 22:02:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan (3):
  tg3: Don't modify ip header fields when doing GSO
  tg3: Prevent page allocation failure during TSO workaround
  tg3: Update copyright and version to 3.137

 drivers/net/ethernet/broadcom/tg3.c |   51 +++++++++++++++++++++++-----------
 drivers/net/ethernet/broadcom/tg3.h |    2 +-
 2 files changed, 35 insertions(+), 18 deletions(-)
