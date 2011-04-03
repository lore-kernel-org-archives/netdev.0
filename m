From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2011-04-03
Date: Sun, 03 Apr 2011 20:44:49 +0100
Message-ID: <1301859889.2935.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9457 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549Ab1DCTox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 15:44:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 9b12c75bf4d58dd85c987ee7b6a4356fdc7c1222:
  David S. Miller (1):
        net: Order ports in same order as addresses in flow objects.

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git master

1. Implement of generic features interface in sfc.
2. Update ethtool_ops documentation.
3. Reimplement ETHTOOL_PHYS_ID as dicussed, dropping the RTNL lock.

Please allow some time for others to review before pulling.

Ben.

Ben Hutchings (6):
      sfc: Move test of rx_checksum_enabled from nic.c to rx.c
      sfc: Implement generic features interface
      ethtool: Convert struct ethtool_ops comment to kernel-doc format
      ethtool: Fill out and update comment for struct ethtool_ops
      ethtool: Change ETHTOOL_PHYS_ID implementation to allow dropping RTNL
      sfc: Implement ethtool_ops::set_phys_id instead of ethtool_ops::phys_id

 drivers/net/sfc/efx.c        |   17 ++++-
 drivers/net/sfc/ethtool.c    |  106 ++++---------------------
 drivers/net/sfc/net_driver.h |    2 -
 drivers/net/sfc/nic.c        |    6 +-
 drivers/net/sfc/rx.c         |    3 +
 include/linux/ethtool.h      |  177 ++++++++++++++++++++++++++++++------------
 net/core/ethtool.c           |   46 +++++++++++-
 7 files changed, 209 insertions(+), 148 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

