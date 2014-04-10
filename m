From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 0/2] fix for cpsw interface up/down with high ethernet traffic
Date: Thu, 10 Apr 2014 14:23:22 +0530
Message-ID: <1397120004-13195-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:36176 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934714AbaDJIxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Apr 2014 04:53:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series fixes the cpsw issue with interface up/dpwn with high
ethernet traffic.

Mugunthan V N (2):
  drivers: net: cpsw: discard all packets received when interface is
    down
  drivers: net: cpsw: enable interrupts after napi enable and clearing
    previous interrupts

 drivers/net/ethernet/ti/cpsw.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

-- 
1.9.2.459.g68773ac
