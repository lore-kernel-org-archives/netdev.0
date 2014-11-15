From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/3] Add temperature reading and registers dump to mv88e6171
Date: Sat, 15 Nov 2014 22:24:50 +0100
Message-ID: <1416086694-15790-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, linux@roeck-us.net,
	Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:32987 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754604AbaKOVZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2014 16:25:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches centralize the temperature sensor reading code, and then
make use of it with the mv88e6171 which has a compatible
sensor. Additionally, support is added for reading the mv88e6171 via
ethtool.

Andrew Lunn (3):
  net: dsa: Centralise code for reading the temperature sensor
  net: dsa: mv88e6171: Add support for reading the temperature
  net: dsa: mv88e6171: Add support for reading switch registers

 drivers/net/dsa/mv88e6123_61_65.c | 50 +--------------------------------------
 drivers/net/dsa/mv88e6171.c       | 21 ++++++++++++++--
 drivers/net/dsa/mv88e6xxx.c       | 48 +++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/mv88e6xxx.h       |  1 +
 4 files changed, 69 insertions(+), 51 deletions(-)

-- 
2.1.3
