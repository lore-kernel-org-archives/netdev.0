From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next v2 0/3] net: fec: driver code clean and bug fix
Date: Thu, 11 Dec 2014 09:20:30 +0800
Message-ID: <1418260833-896-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0101.outbound.protection.outlook.com ([157.56.111.101]:29920
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933521AbaLKByJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 20:54:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch serial include code clean and bug fix:
Patch#1: avoid dummy operation during suspend/resume test.
Patch#2: bug fix for i.MX6SX SOC that clean all interrupt events during MAC initial process.
Patch#3: before phy device link status is up, only enable MDIO bus interrupt.

V2:
- Modify the comment form from David's suggestion.

Fugang Duan (3):
  net: fec: reset fep link status in suspend function
  net: fec: clear all interrupt events to support i.MX6SX
  net: fec: only enable mdio interrupt before phy device link up

 drivers/net/ethernet/freescale/fec_main.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

-- 
1.7.8
