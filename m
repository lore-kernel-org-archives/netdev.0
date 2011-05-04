From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCHv3 0/2] Loopback
Date: Tue,  3 May 2011 18:18:53 -0700
Message-ID: <1304471935-402-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: Matt Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:32935 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754878Ab1EDBTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2011 21:19:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

First patch is the repost of the earlier loopback patch. tg3 implementation / patch demonstrates one such usage and I have incarporated changes suggested by Matt and Joe.

Mahesh Bandewar (2):
  net: Allow ethtool to set interface in loopback mode.
  tg3: Allow ethtool to enable/disable loopback.

 drivers/net/tg3.c              |   57 ++++++++++++++++++++++++++++++++++++++++
 include/linux/netdevice.h      |    3 +-
 net/core/ethtool.c             |    2 +-
 3 files changed, 59 insertions(+), 2 deletions(-)

-- 
1.7.3.1

