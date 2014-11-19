From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH v2 net-next 0/2] bonding: Introduce 4 AD link speed
Date: Wed, 19 Nov 2014 16:48:57 +0800
Message-ID: <1416386939-24591-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Eric Dumazet <edumazet@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jianhua Xie <Jianhua.Xie@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bon0139.outbound.protection.outlook.com ([157.56.111.139]:13760
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750821AbaKSIu1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Nov 2014 03:50:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

The speed field of AD Port Key was based on bitmask, it supported 5
kinds of link speed at most, as there were only 5 bits in the speed
field of the AD Port Key.  This patches series change the speed type
(AD_LINK_SPEED_BITMASK) from bitmask to enum type in order to enhance
speed type from 5 to 32, and then introduce 4 AD link speed to fix
agg_bandwidth.

Jianhua Xie (2):
  bonding: change AD_LINK_SPEED_BITMASK to enum to suport more speed
  bonding: Introduce 4 AD link speed to fix agg_bandwidth

 drivers/net/bonding/bond_3ad.c | 102 ++++++++++++++++++++++++++++-------------
 1 file changed, 70 insertions(+), 32 deletions(-)

-- 
v2:
 * Use an enum type to instead of the bitmask, not expand speed field, 

v1:
 * Compress RFC patches #2 to #5 into one single patch.
 * Fix inexact commit information.

2.1.0.27.g96db324
