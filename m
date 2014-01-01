From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 0/4] bnx2: Add better support for auto-mdix
Date: Tue, 31 Dec 2013 23:22:31 -0800
Message-ID: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:52675 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbaAAG6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 01:58:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Chan (4):
  bnx2: Advertise nothing when speed is forced
  bnx2: Enable auto-mdix when autoneg is disabled.
  bnx2: Report MDI/MDIX status to ethtool.
  bnx2: Update version to 2.2.5.

 drivers/net/ethernet/broadcom/bnx2.c |   56 ++++++++++++++++++++++++----------
 drivers/net/ethernet/broadcom/bnx2.h |   10 ++++++
 2 files changed, 50 insertions(+), 16 deletions(-)
