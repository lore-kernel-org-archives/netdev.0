From: Fugang Duan <b38611@freescale.com>
Subject: [PATCH net-next 0/3] net: fec: driver code clean and bug fix
Date: Wed, 10 Dec 2014 17:54:46 +0800
Message-ID: <1418205289-7730-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <bhutchings@solarflare.com>,
	<stephen@networkplumber.org>, <b38611@freescale.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0138.outbound.protection.outlook.com ([65.55.169.138]:20689
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752117AbaLJK2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Dec 2014 05:28:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch serial include code clean and bug fix:
Patch#1: avoid dummy operation during suspend/resume test.
Patch#2: bug fix for i.MX6SX SOC that clean all interrupt events during MAC initial process.
Patch#3: before phy device link status is up, only enable MDIO bus interrupt.

Fugang Duan (3):
  net: fec: reset fep link status in suspend function
  net: fec: clear all interrupt events to support i.MX6SX
  net: fec: only enable mdio interrupt before phy device link up

 drivers/net/ethernet/freescale/fec_main.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

-- 
1.7.8
