From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net 0/3]tg3: synchronize_irq() should be called without taking locks
Date: Tue, 13 Jan 2015 22:30:39 -0800
Message-ID: <1421217039-11689-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <mchan@broadcom.com>,
	<peter@hurleysoftware.com>,
	Prashant Sreedharan <prashant@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:63483 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbbANGtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2015 01:49:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prashant Sreedharan (3):
  tg3_timer() should grab tp->lock before checking for tp->irq_sync
  tg3_reset_task() needs to use rtnl_lock to synchronize
  Release tp->lock before invoking synchronize_irq()

Our QA team is validating this patch set, we need few days before merging

 drivers/net/ethernet/broadcom/tg3.c |   23 ++++++++++++++++++++---
 1 files changed, 20 insertions(+), 3 deletions(-)
