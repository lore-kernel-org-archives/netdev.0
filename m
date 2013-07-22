From: Simon Horman <horms+renesas@verge.net.au>
Subject: [PATCH 0/2] sh_eth: Add support for r8a7790 SoC
Date: Mon, 22 Jul 2013 16:15:46 +0900
Message-ID: <1374477348-1349-1-git-send-email-horms+renesas@verge.net.au>
Cc: Magnus Damm <magnus.damm@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Simon Horman <horms+renesas@verge.net.au>
To: netdev@vger.kernel.org, linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this short series enhances the sh_eth driver for use with the r8a7790 SoC.

Changes since v2:

* Removed "sh_eth: add support for gpio reset" as it appears unnecessary
  and I am not entirely confident is is correct.
* Updated "sh_eth: Add support for r8a7790 SoC" to
  refer to R8A777x intead of R8A7779.

Simon Horman (2):
  sh_eth: add support for RMIIMODE register
  sh_eth: Add support for r8a7790 SoC

 drivers/net/ethernet/renesas/Kconfig  |  2 +-
 drivers/net/ethernet/renesas/sh_eth.c | 25 +++++++++++++++++++++++++
 drivers/net/ethernet/renesas/sh_eth.h |  2 ++
 3 files changed, 28 insertions(+), 1 deletion(-)

-- 
1.8.2.1

