From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net 0/2] sfc: aRFS fixes
Date: Thu, 26 May 2016 17:00:18 +0100
Message-ID: <57471D92.2000708@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:38233 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754413AbcEZQA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 12:00:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The issue fixed in patch #1 was found two years ago and might not still
 happen on current kernels, but (a) we didn't figure out what caused it,
 and (b) the fix should be harmless even if it's unnecessary.

Edward Cree (1):
  sfc: handle nonlinear SKBs in efx_filter_rfs()

Jon Cooper (1):
  sfc: Track RPS flow IDs per channel instead of per function

 drivers/net/ethernet/sfc/efx.c        | 32 ++++++++++++++---
 drivers/net/ethernet/sfc/net_driver.h | 12 ++++---
 drivers/net/ethernet/sfc/rx.c         | 68 ++++++++++++++++++++++-------------
 3 files changed, 79 insertions(+), 33 deletions(-)
