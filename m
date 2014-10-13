From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net PATCH 0/3] bug fixes for davinci_cpdma and cpsw drivers
Date: Mon, 13 Oct 2014 22:21:04 +0530
Message-ID: <1413219067-15328-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:57828 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895AbaJMQvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 12:51:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Mugunthan V N (3):
  drivers: net: davinci_cpdma: remove kfree on objects allocated with
    devm_* apis
  drivers: net: davinci_cpdma: remove spinlock as SOFTIRQ-unsafe lock
    order detected
  drivers: net: cpsw: remove child devices while driver detach

 drivers/net/ethernet/ti/cpsw.c          | 10 ++++++++++
 drivers/net/ethernet/ti/davinci_cpdma.c |  5 -----
 2 files changed, 10 insertions(+), 5 deletions(-)

-- 
2.1.1.332.g0bf7dd6
