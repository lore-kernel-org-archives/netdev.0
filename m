From: <Woojung.Huh@microchip.com>
Subject: [PATCH 0/4 net] lan78xx: updates & fixes
Date: Mon, 25 Jan 2016 23:00:15 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049DEA9@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:9884 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932373AbcAYXAR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 18:00:17 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Woojung Huh (4):
  lan78xx: change to use updated phy-ignore-interrupts     
  lan78xx: replace devid to chipid & chiprev
  lan78xx: add to handle mux control per chip id
  lan78xx: throttle tx path per usb speed

 drivers/net/usb/lan78xx.c | 137 ++++++++++++++++++++++++++++++----------------
 drivers/net/usb/lan78xx.h |   1 +
 2 files changed, 92 insertions(+), 46 deletions(-)

-- 
2.1.4
