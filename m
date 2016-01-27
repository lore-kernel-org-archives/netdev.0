From: <Woojung.Huh@microchip.com>
Subject: [PATCH 0/3] lan78xx: update and fixes
Date: Wed, 27 Jan 2016 22:57:51 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4049F331@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:14312 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S934135AbcA0W5x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 17:57:53 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Woojung Huh (3):
  lan78xx: change to use updated phy-ignore-interrupts
  lan78xx: Add to handle mux control per chip id
  lan78xx: throttle TX path at slower than SuperSpeed USB

 drivers/net/usb/lan78xx.c | 132 ++++++++++++++++++++++++++++++----------------
 1 file changed, 88 insertions(+), 44 deletions(-)

-- 
2.7.0
