From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH 0/2] net: sh_eth: Fix two issues in sh_eth_rx()
Date: Mon, 9 Jun 2014 19:39:07 +0900
Message-ID: <53958ECB.6080203@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: SH-Linux <linux-sh@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I used the latest net.git repository.
 commit id = 87757a917b0b3c0787e0563c679762152be81312
 (net: force a list_del() in unregister_netdevice_many())

I tested these patches on r8a7790.

Yoshihiro Shimoda (2):
  net: sh_eth: Fix receive packet "exceeded" condition in sh_eth_rx()
  net: sh_eth: Fix timing of RACT setting in sh_eth_rx()

 drivers/net/ethernet/renesas/sh_eth.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

-- 
1.7.9.5

