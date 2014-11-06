From: Xie Jianhua <Jianhua.Xie@freescale.com>
Subject: [PATCH RFC net-next 0/5] *** Introduce 4 AD link speed ***
Date: Thu, 6 Nov 2014 19:52:47 +0800
Message-ID: <1415274772-8029-1-git-send-email-Jianhua.Xie@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jianhua Xie <jianhua.xie@freescale.com>,
	Jianhua Xie <Jianhua.Xie@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0119.outbound.protection.outlook.com ([65.55.169.119]:44824
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750846AbaKFLyS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Nov 2014 06:54:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jianhua Xie <Jianhua.Xie@freescale.com>

User Key bits in Port key of AD mode are yet not used.  This series
expands speed type bits and shrinks unused user Key bits in AD mode
Port Key, introduces 4 AD link speed: 2.5G/20G/40G/56G, and fixes
aggregated link bandwidth calculation based on new link speed.

Jianhua Xie (5):
  bonding: Expand speed type for AD Port Key
  bonding: Introduce 2.5Gbps AD link speed
  bonding: Introduce 20Gbps AD link speed
  bonding: Introduce 40Gbps AD link speed
  bonding: Introduce 56Gbps AD link speed

 drivers/net/bonding/bond_3ad.c | 44 ++++++++++++++++++++++++++++++++++++++----
 1 file changed, 40 insertions(+), 4 deletions(-)

-- 
2.1.0.27.g96db324
