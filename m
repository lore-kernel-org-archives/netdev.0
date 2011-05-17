From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2011-05-17
Date: Tue, 17 May 2011 16:59:48 +0100
Message-ID: <1305647988.2848.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:25543 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755341Ab1EQP7v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 11:59:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 7be799a70ba3dd90a59e8d2c72bbe06020005b3f:

  ipv4: Remove rt->rt_dst reference from ip_forward_options(). (2011-05-13 17:31:02 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git master

Miscellaneous bug fixes.

Ben.

Ben Hutchings (3):
      sfc: Fix return value from efx_ethtool_set_rx_ntuple()
      sfc: Fix TX queue numbering when separate_tx_channels=1
      sfc: Use netif_device_{detach,attach}() around reset and self-test

 drivers/net/sfc/efx.c        |   21 +++++++++++++++------
 drivers/net/sfc/ethtool.c    |    5 +++--
 drivers/net/sfc/net_driver.h |    4 +---
 drivers/net/sfc/selftest.c   |   11 +++++------
 drivers/net/sfc/tx.c         |    9 +++++----
 5 files changed, 29 insertions(+), 21 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

