From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 0/2] net, sfc: Fix number of RX queues
Date: Thu, 23 Sep 2010 21:18:38 +0100
Message-ID: <1285273118.7794.23.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:48982 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753502Ab0IWUSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 16:18:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This distinguishes the maximum and actual numbers of RX queues, adds a
function to set the actual number, and changes sfc to use it.  Other
multiqueue drivers should presumably be updated similarly.

Ben.

Ben Hutchings (2):
  net: Allow changing number of RX queues after device allocation
  sfc: Use proper functions to set core RX and TX queue counts

 drivers/net/sfc/efx.c     |    3 ++-
 include/linux/netdevice.h |   14 ++++++++++++++
 net/core/dev.c            |   43 +++++++++++++++++++++++++++++++++++++++----
 net/core/net-sysfs.c      |   34 +++++++++++++++++++---------------
 net/core/net-sysfs.h      |    4 ++++
 5 files changed, 78 insertions(+), 20 deletions(-)

-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

