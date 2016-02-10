From: <Woojung.Huh@microchip.com>
Subject: [PATCH net-next 0/3] lan78xx: driver update
Date: Wed, 10 Feb 2016 21:13:36 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D404AB9EB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:15535 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750759AbcBJVNh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 16:13:37 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patch series update to get correct features from phylib and
add new ethtool functions of set_pauseparam and get_pauseparam.

Woojung Huh (3):
  lan78xx: replace devid to chipid & chiprev
  lan78xx: setting phy features in phy driver
  lan78xx: add ethtool set & get pause functions

 drivers/net/phy/microchip.c |  10 +++-
 drivers/net/usb/lan78xx.c   | 115 ++++++++++++++++++++++++++++++++++++--------
 drivers/net/usb/lan78xx.h   |   1 +
 3 files changed, 105 insertions(+), 21 deletions(-)

-- 
2.7.0
