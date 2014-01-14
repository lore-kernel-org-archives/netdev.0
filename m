From: Arnaud Ebalard <arno@natisbad.org>
Subject: [PATCH net-next 0/2] net: mvneta: simple cleanups
Date: Wed, 15 Jan 2014 00:45:31 +0100
Message-ID: <cover.1389742334.git.arno@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:44147 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbaANXps (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 18:45:48 -0500
Received: from smtp.natisbad.org (unknown [81.57.185.249])
	by smtp1-g21.free.fr (Postfix) with ESMTP id C8267940005
	for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 00:45:39 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Those two patches are intended for net-next. They apply on top of
performance improvements patches from Willy for mvneta driver.
They provide some simple cleanups for unused variables, function
params or return values.

Arnaud Ebalard (2):
  net: mvneta: mvneta_tx_done_gbe() cleanups
  net: mvneta: make mvneta_txq_done() return void

 drivers/net/ethernet/marvell/mvneta.c | 26 ++++++++------------------
 1 file changed, 8 insertions(+), 18 deletions(-)

-- 
1.8.5.2
