From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCHv2 0/2] net: mvneta: big endian support
Date: Mon, 29 Jul 2013 15:21:26 +0200
Message-ID: <1375104088-24654-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:47874 "EHLO
	mail.free-electrons.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751183Ab3G2NVa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 09:21:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

You'll find in this patch series two small patches that add support
for big-endian in the mvneta driver, for the network interface found
in ARM Marvell Armada 370 and Armada XP SOCs. They are based on
3.11-rc3.

Changes since v1:
 * Rebased on top of 3.11-rc2.
 * Version sent once net-next is opened.

Thanks,

Thomas

Thomas Petazzoni (2):
  net: mvneta: move the RX and TX desc macros outside of the structs
  net: mvneta: support big endian

 drivers/net/ethernet/marvell/mvneta.c | 61 +++++++++++++++++++++++++++--------
 1 file changed, 47 insertions(+), 14 deletions(-)

-- 
1.8.1.2
