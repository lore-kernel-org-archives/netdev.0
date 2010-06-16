From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 0/9] cxgb4 update
Date: Wed, 16 Jun 2010 15:01:07 -0700
Message-ID: <1276725676-31514-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23472 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754649Ab0FPWBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jun 2010 18:01:17 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5GM1H75032115
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:17 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o5GM1GtH031568
	for <netdev@vger.kernel.org>; Wed, 16 Jun 2010 15:01:16 -0700
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o5GM1GAF031567
	for netdev@vger.kernel.org; Wed, 16 Jun 2010 15:01:16 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's a series of 9 patches for the cxgb4 driver.  The changes include
support for larger flash memories, addition of EEH, an update to latest
fw api, and assorted few liners.  All patches are for net-next.

 drivers/net/cxgb4/cxgb4.h      |    6 +-
 drivers/net/cxgb4/cxgb4_main.c |  281 ++++++++++++++++++++++++++++++----------
 drivers/net/cxgb4/cxgb4_uld.h  |    2 +
 drivers/net/cxgb4/l2t.c        |    7 +
 drivers/net/cxgb4/t4_hw.c      |   94 ++++++++++----
 drivers/net/cxgb4/t4_hw.h      |    2 -
 drivers/net/cxgb4/t4_regs.h    |    3 +
 drivers/net/cxgb4/t4fw_api.h   |   36 ++++--
 8 files changed, 326 insertions(+), 105 deletions(-)
