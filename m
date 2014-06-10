From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH v2 0/2] net: sh_eth: Fix two issues in sh_eth_rx()
Date: Tue, 10 Jun 2014 09:40:04 +0900
Message-ID: <539653E4.9080808@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:19029 "EHLO
	relmlie1.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S964982AbaFJAkM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 20:40:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I used the latest net.git repository.
 commit id = 87757a917b0b3c0787e0563c679762152be81312
 (net: force a list_del() in unregister_netdevice_many())

I tested these patches on r8a7790.

Changes from v1:
 - Remove unnecessary parens in patch 1.

Yoshihiro Shimoda (2):
  net: sh_eth: Fix receive packet "exceeded" condition in sh_eth_rx()
  net: sh_eth: Fix timing of RACT setting in sh_eth_rx()

 drivers/net/ethernet/renesas/sh_eth.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

-- 
1.7.9.5
