From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: RSS enhancements
Date: Wed, 4 May 2016 17:56:15 +0100
Message-ID: <572A29AF.1040607@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Pieczko <dpieczko@solarflare.com>
To: <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo04.seg.att.com ([209.65.160.86]:16700 "EHLO
	nbfkord-smmo04.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752148AbcEDQ4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 12:56:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Pieczko (1):
  sfc: allocate rx pages on the same node as the interrupt

Edward Cree (1):
  sfc: Support setting rss_cpus to 'cores', 'packages' or 'hyperthreads'

 drivers/net/ethernet/sfc/efx.c        | 181 ++++++++++++++++++++++++++++------
 drivers/net/ethernet/sfc/net_driver.h |   3 +
 drivers/net/ethernet/sfc/rx.c         |  18 +++-
 3 files changed, 169 insertions(+), 33 deletions(-)
