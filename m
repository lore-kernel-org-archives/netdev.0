From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 0/2] Device statistics type fixes
Date: Tue, 08 Jun 2010 19:20:49 +0100
Message-ID: <1276021249.2185.55.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:44624 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675Ab0FHSUw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jun 2010 14:20:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While messing about with net_device_stats types, I spotted a couple of
drivers printing device statistics using the format %ld.

Ben.

Ben Hutchings (2):
  usbnet: Print device statistics as unsigned
  irttp: Print device parameters and statistics as unsigned

 drivers/net/usb/usbnet.c |    2 +-
 net/irda/irttp.c         |   14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

