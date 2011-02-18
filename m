From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2011-02-18
Date: Fri, 18 Feb 2011 16:00:39 +0000
Message-ID: <1298044839.2570.7.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>,
	Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:38770 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856Ab1BRQAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Feb 2011 11:00:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit f878b995b0f746f5726af9e66940f3bf373dae91:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6 (2011-02-15 12:25:19 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem

Add support for RFS acceleration in the sfc driver, and allow it to be
enabled and disabled dynamically using ethtool.

Ben.

Ben Hutchings (3):
      net: RPS: Make hardware-accelerated RFS conditional on NETIF_F_NTUPLE
      sfc: Limit filter search depth further for performance hints (i.e. RFS)
      sfc: Implement hardware acceleration of RFS

 drivers/net/sfc/efx.c        |   49 +++++++++++++++++-
 drivers/net/sfc/efx.h        |   15 +++++
 drivers/net/sfc/filter.c     |  117 ++++++++++++++++++++++++++++++++++++++++--
 drivers/net/sfc/net_driver.h |    3 +
 net/core/dev.c               |    3 +-
 5 files changed, 180 insertions(+), 7 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

