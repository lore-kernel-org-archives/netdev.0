From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 0/2] net: mvneta: fix usage as a module
Date: Wed, 26 Mar 2014 00:25:40 +0100
Message-ID: <1395789942-20764-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Steve McIntyre <steve@einval.com>,
	linux-arm-kernel@lists.infradead.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:50166 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751868AbaCYXZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 19:25:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

The following set of two patches fix the usage of the mvneta driver
when built as a module, and used in RGMII configurations. It is
somewhat similar to a previous fix that was made by Arnaud Patard, but
which was limited to SGMII configurations.

Thanks,

Thomas

Thomas Petazzoni (2):
  net: mvneta: rename MVNETA_GMAC2_PSC_ENABLE to MVNETA_GMAC2_PCS_ENABLE
  net: mvneta: fix usage as a module on RGMII configurations

 drivers/net/ethernet/marvell/mvneta.c | 43 ++++++++---------------------------
 1 file changed, 9 insertions(+), 34 deletions(-)

-- 
1.8.3.2
