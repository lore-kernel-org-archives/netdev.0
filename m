From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [net-next 0/3] net: bcmgenet: warnings fixes
Date: Thu, 20 Feb 2014 12:53:48 -0800
Message-ID: <1392929631-7685-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:12461 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbaBTUyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Feb 2014 15:54:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This small patchset fixes some warnings reported by static analysis tools
such as smatch and the 0-day test robot. Finally a patch removes some
dead code in the driver.

Thanks!

Florian Fainelli (3):
  net: bcmgenet: drop checks on priv->phydev
  net: bcmgenet: fix warning on ndo_select_queue
  net: bcmgenet: remove commented code in bcmgenet_xmit()

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 22 +++++++---------------
 1 file changed, 7 insertions(+), 15 deletions(-)

-- 
1.8.3.2
