From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/3] EEE support for mv88e6172
Date: Tue, 10 Mar 2015 23:05:56 +0100
Message-ID: <1426025160-13992-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57213 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311AbbCJWJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 18:09:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset contains two cleanups and then adds EEE support
to the mv88e6172, using the base provided by Guenter Roeck

Tested on a WRT1900AC with mv88e6172 and DIR665 with mv88e6171.

Andrew Lunn (3):
  net: dsa: Centralise getting switch id
  net: dsa: mv6171: Add defines for switch product IDs
  net: dsa: mv88e6171: Add EEE support to the mv88e6172

 drivers/net/dsa/mv88e6171.c | 32 ++++++++++++++++++++++++++++++--
 drivers/net/dsa/mv88e6352.c |  2 --
 drivers/net/dsa/mv88e6xxx.c |  2 ++
 3 files changed, 32 insertions(+), 4 deletions(-)

-- 
2.1.4
