From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH 0/2] CPSW interrupt handling cleanup and performance improvement
Date: Mon, 27 Jul 2015 16:48:59 +0530
Message-ID: <1437995941-5857-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:43490 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071AbbG0LTT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 07:19:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series removes the irq controller disable interrupt and
adding a napi for tx event handling which improves the performance by
180Mbps on dra7-evm

[  5] local 192.168.10.116 port 5001 connected with 192.168.10.125 port 44174
[  5]  0.0-60.0 sec  1.46 GBytes   209 Mbits/sec
[  4] local 192.168.10.116 port 5001 connected with 192.168.10.125 port 33954
[  4]  0.0-60.0 sec  2.72 GBytes   390 Mbits/sec

Mugunthan V N (2):
  drivers: net: cpsw: remove  disable_irq/enable_irq as irq can be
    masked from cpsw itself
  drivers: net: cpsw: add separate napi for tx packet handling for
    performance improvment

 drivers/net/ethernet/ti/cpsw.c | 88 +++++++++++++++++++++++-------------------
 1 file changed, 49 insertions(+), 39 deletions(-)

-- 
2.5.0.rc3.2.g6f9504c
