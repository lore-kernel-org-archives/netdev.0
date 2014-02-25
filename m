From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [net-next v2 0/3] net: bcmgenet: trivial fixes
Date: Mon, 24 Feb 2014 16:56:10 -0800
Message-ID: <1393289773-9473-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:12410 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752461AbaBYA4Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:56:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patchset incorporates some trivial fixes based on a report
from Dan Carpenter. Thanks!

Florian Fainelli (3):
  net: bcmgenet: drop checks on priv->phydev
  net: bcmgenet: remove commented code in bcmgenet_xmit()
  net: bcmgenet: remove unused bh_lock member

 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 21 ++++++---------------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h |  1 -
 2 files changed, 6 insertions(+), 16 deletions(-)

-- 
1.8.3.2
