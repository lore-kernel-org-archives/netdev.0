From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/2] Add support for PHY packet generator to ethtool(1)
Date: Wed, 17 Feb 2016 21:37:14 +0100
Message-ID: <1455741436-25728-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50615 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965253AbcBQUhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 15:37:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Import the latests ethtool.h and add an option to make use of the
PHY packet generators. 

Andrew Lunn (2):
  ethtool-copy.h: sync with net
  ethtool: Add --phy_pkt_gen command

 ethtool-copy.h | 119 ++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 ethtool.8.in   |  30 +++++++++++++++
 ethtool.c      |  44 +++++++++++++++++++++
 internal.h     |   3 ++
 4 files changed, 187 insertions(+), 9 deletions(-)

-- 
2.1.4
