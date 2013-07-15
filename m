From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 0/2] net: mvneta: big endian support
Date: Mon, 15 Jul 2013 15:27:24 +0200
Message-ID: <1373894846-1147-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: linux-arm-kernel@lists.infradead.org,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:57027 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756504Ab3GON1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jul 2013 09:27:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

You'll find in this patch series two small patches that add support
for big-endian in the mvneta driver, for the network interface found
in ARM Marvell Armada 370 and Armada XP SOCs. They are based on
3.11-rc1.

Thanks,

Thomas

Thomas Petazzoni (2):
  net: mvneta: move the RX and TX desc macros outside of the structs
  net: mvneta: support big endian

 drivers/net/ethernet/marvell/mvneta.c | 61 +++++++++++++++++++++++++++--------
 1 file changed, 47 insertions(+), 14 deletions(-)

-- 
1.8.1.2
