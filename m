From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH v1 net-next 0/2] bonding: Introduce 4 AD link speed
Date: Mon, 10 Nov 2014 15:16:39 +0800
Message-ID: <1415603801-21285-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Jianhua Xie <Jianhua.Xie@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0118.outbound.protection.outlook.com ([157.56.110.118]:20896
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751297AbaKJHcq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Nov 2014 02:32:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

User Key bits in Port key of AD mode are yet not used.  This series
expands speed type bits and shrinks unused user Key bits in AD mode
Port Key, introduces 4 AD link speed: 2.5G/20G/40G/56G, and fixes
aggregated link bandwidth calculation based on new link speed.

Jianhua Xie (2):
  bonding: Expand speed type bits of the AD Port Key
  bonding: Introduce 4 AD link speed to fix agg_bandwidth

 drivers/net/bonding/bond_3ad.c | 44 ++++++++++++++++++++++++++++++++++++++----
 1 file changed, 40 insertions(+), 4 deletions(-)

-- 
Changes in v1:
 * Compress RFC patches #2 to #5 into one single patch.
 * Fix inexact commit information.

2.1.0.27.g96db324
