From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 0/9] cxgb4 update v2
Date: Fri, 18 Jun 2010 13:05:26 -0700
Message-ID: <1276891535-13967-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:28151 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933072Ab0FRUMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jun 2010 16:12:20 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o5IKCJQE018644
	for <netdev@vger.kernel.org>; Fri, 18 Jun 2010 13:12:20 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o5IK5ZFQ014009
	for <netdev@vger.kernel.org>; Fri, 18 Jun 2010 13:05:35 -0700
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o5IK5ZrN014008
	for netdev@vger.kernel.org; Fri, 18 Jun 2010 13:05:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's v2 of the cxgb4 series.  Of the 9 patches patch 8 has been updated to
fix the iw_cxgb4 breakage and the rest are as before.

 drivers/net/cxgb4/cxgb4.h      |    6 +-
 drivers/net/cxgb4/cxgb4_main.c |  281 ++++++++++++++++++++++++++++++----------
 drivers/net/cxgb4/cxgb4_uld.h  |    2 +
 drivers/net/cxgb4/l2t.c        |    7 +
 drivers/net/cxgb4/t4_hw.c      |   94 ++++++++++----
 drivers/net/cxgb4/t4_hw.h      |    2 -
 drivers/net/cxgb4/t4_regs.h    |    3 +
 drivers/net/cxgb4/t4fw_api.h   |   34 ++++-
 8 files changed, 325 insertions(+), 104 deletions(-)
