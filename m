From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 0/3] net: dsa: cleanup dsa driver
Date: Tue, 27 Oct 2015 17:35:46 +0100
Message-ID: <562FA7E2.8020703@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	vivien.didelot@savoirfairelinux.com,
	Fabian Frederick <fabf@skynet.be>,
	Pavel Nakonechny <pavel.nakonechny@skitlab.ru>,
	Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34886 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932466AbbJ0Qfu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 12:35:50 -0400
Received: by wicll6 with SMTP id ll6so167891581wic.0
        for <netdev@vger.kernel.org>; Tue, 27 Oct 2015 09:35:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the previously introduced remove callback for DSA driver  in :
http://marc.info/?i=562F8ED7.2000804%40baylibre.com
Add remove callback for bcm_sf2 and mv88e6xxx drivers.

This patch was not tested due of a lack of hardware.

Neil Armstrong (3):
  net: dsa: bcm_sf2: cleanup resources in remove callback
  net: dsa: mv88e6xxx: add common and ppu remove function
  net: dsa: make usage of mv88e6xxx common remove function

 drivers/net/dsa/bcm_sf2.c         | 20 ++++++++++++++++++++
 drivers/net/dsa/mv88e6123_61_65.c |  1 +
 drivers/net/dsa/mv88e6131.c       |  8 ++++++++
 drivers/net/dsa/mv88e6171.c       |  1 +
 drivers/net/dsa/mv88e6352.c       |  1 +
 drivers/net/dsa/mv88e6xxx.c       | 18 ++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  2 ++
 7 files changed, 51 insertions(+)

-- 
1.9.1
