From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 0/2] Loopback
Date: Thu, 28 Apr 2011 16:33:17 -0700
Message-ID: <1304033599-8395-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>,
	Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:2047 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445Ab1D1Xdi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 19:33:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch is the repost of the earlier loopback patch. tg3 implementation / patch demonstrates one such usage.

Mahesh Bandewar (2):
  net: Allow ethtool to set interface in loopback mode.
  tg3: Add code to allow ethtool to enable/disable loopback.

 drivers/net/tg3.c         |   32 ++++++++++++++++++++++++++++++++
 include/linux/netdevice.h |    3 ++-
 net/core/ethtool.c        |    2 +-
 3 files changed, 35 insertions(+), 2 deletions(-)

-- 
1.7.3.1

