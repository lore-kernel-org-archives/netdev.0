From: Joe Perches <joe@perches.com>
Subject: [PATCH V2 net-next 0/3] bnx2x: Message logging cleanups
Date: Sun, 14 Aug 2011 15:16:18 -0700
Message-ID: <cover.1313360100.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wondertoys-mx.wondertoys.net ([206.117.179.246]:43872 "EHLO
	labridge.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754546Ab1HNWQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Aug 2011 18:16:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joe Perches (3):
  bnx2x: Remove local defines for %pM and mac address
  bnx2x: Coalesce pr_cont uses and fix DP typos
  bnx2x: Use pr_fmt and message logging cleanups

 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h        |   67 ++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c    |   48 ++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h    |    4 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c    |    5 +-
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |   23 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |  153 ++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   |   72 ++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c     |   67 ++++-----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c  |   46 +++---
 9 files changed, 244 insertions(+), 241 deletions(-)

-- 
1.7.6.405.gc1be0

