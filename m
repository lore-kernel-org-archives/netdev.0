From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: [PATCH net-next 1/5] net: sh_eth: add the value of tsu to the SH7757's
 GETHER
Date: Thu, 16 Feb 2012 12:54:51 +0900
Message-ID: <4F3C7E0B.1080001@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor1.renesas.com ([210.160.252.171]:47347 "EHLO
	relmlor1.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995Ab2BPDyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 22:54:54 -0500
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor1.idc.renesas.com ( SJSMS)
 with ESMTP id <0LZG00D5RW7FYR40@relmlor1.idc.renesas.com> for
 netdev@vger.kernel.org; Thu, 16 Feb 2012 12:54:51 +0900 (JST)
Received: from relmlac4.idc.renesas.com ([10.200.69.24])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0LZG008JDW7FY730@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Thu, 16 Feb 2012 12:54:51 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The SH7757's GETHER has TSU registers. So, this patch adds the value
of ".tsu = 1" in the sh_eth_cpu_data.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
---
 drivers/net/ethernet/renesas/sh_eth.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
index 98062bf..8f53b5a 100644
--- a/drivers/net/ethernet/renesas/sh_eth.c
+++ b/drivers/net/ethernet/renesas/sh_eth.c
@@ -268,6 +268,7 @@ static struct sh_eth_cpu_data sh_eth_my_cpu_data_giga = {
 	.rpadir_value   = 2 << 16,
 	.no_trimd	= 1,
 	.no_ade		= 1,
+	.tsu		= 1,
 };

 static struct sh_eth_cpu_data *sh_eth_get_cpu_data(struct sh_eth_private *mdp)
-- 
1.7.1
