From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6 0/2] be2net: fixes
Date: Thu, 27 Oct 2011 22:41:47 +0530
Message-ID: <900362ce-e840-44cb-bfcf-72eba609edf3@exht2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht2.emulex.com ([138.239.113.184]:6187 "EHLO
	exht2.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754207Ab1J0Lp1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 07:45:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Somnath Kotur (2):
  be2net: Refactored be_cmds.c file.
  be2net: Changing MAC Address of a VF (in SR-IOV case) was broken.

 drivers/net/ethernet/emulex/benet/be_cmds.c |  400 ++++++++-------------------
 drivers/net/ethernet/emulex/benet/be_main.c |   28 +-
 2 files changed, 133 insertions(+), 295 deletions(-)
