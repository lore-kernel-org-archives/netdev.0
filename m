From: Kristoffer Glembo <kristoffer@gaisler.com>
Subject: [PATCH 0/1 V5] net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver
Date: Thu, 28 Jan 2010 08:43:48 +0100
Message-ID: <1264664629-25128-1-git-send-email-kristoffer@gaisler.com>
Cc: davem@davemloft.net, shemminger@vyatta.com,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail168c2.megamailservers.com ([69.49.111.68]:33199 "EHLO
	mail168c2.megamailservers.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754944Ab0A1HoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2010 02:44:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds device driver for Aeroflex Gaisler 10/100 and 10/100/1G Ethernet MAC IP cores.

Issues pointed out by Stephen Hemminger fixed:
Added ethtool support, fixed erronous freeing of SKB, removed private stats structure, cleaned up ugly macro.

Kristoffer Glembo (1):
  net: Add Aeroflex Gaisler 10/100/1G Ethernet MAC driver

 MAINTAINERS          |    6 +
 drivers/net/Kconfig  |    9 +
 drivers/net/Makefile |    1 +
 drivers/net/greth.c  | 1668 ++++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/greth.h  |  149 +++++
 5 files changed, 1833 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/greth.c
 create mode 100644 drivers/net/greth.h

