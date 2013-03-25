From: Sekhar Nori <nsekhar@ti.com>
Subject: [PATCH net-next 0/2] net/davinci_emac updates
Date: Mon, 25 Mar 2013 14:55:45 +0530
Message-ID: <1364203547-2960-1-git-send-email-nsekhar@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	Sekhar Nori <nsekhar@ti.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:47955 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757757Ab3CYJ07 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 05:26:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series converts davinci_emac driver to use
clk_prepare/unprepare in preparation towards common
clock migration for DaVinci. While at it, also introduce
a patch to start using devres APIs to simplify error
handling during probe.

Sekhar Nori (2):
  net/davinci_emac: use devres APIs
  net/davinci_emac: use clk_{prepare|unprepare}

 drivers/net/ethernet/ti/davinci_emac.c |   55 ++++++++++++++++----------------
 1 file changed, 28 insertions(+), 27 deletions(-)

-- 
1.7.10.1
