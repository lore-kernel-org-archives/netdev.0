From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH 0/2] ethtool(1) support for reading Phy stats
Date: Wed, 23 Dec 2015 12:58:29 +0100
Message-ID: <1450871911-19509-1-git-send-email-andrew@lunn.ch>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48602 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934346AbbLWL64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2015 06:58:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to ethertool(1) for reading phy statistics. The mechanism
is the same for reading MAC stats.

Andrew Lunn (2):
  ethtool-copy.h: sync with net
  ethtool: Add PHY statistics support

 ethtool-copy.h | 55 +++++++++++++++++++++++++++++++++++++++++++++++------
 ethtool.8.in   |  6 ++++++
 ethtool.c      | 60 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 115 insertions(+), 6 deletions(-)

-- 
2.1.4
