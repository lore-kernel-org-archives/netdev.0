From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-2.6 2011-04-13
Date: Wed, 13 Apr 2011 00:47:45 +0100
Message-ID: <1302652065.2880.28.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:12363 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757163Ab1DLXrs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 19:47:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 4a9f65f6304a00f6473e83b19c1e83caa1e42530:

  caif: performance bugfix - allow radio stack to prioritize packets. (2011-04-11 13:15:58 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-2.6.git sfc-2.6.39

These fix some bugs found in internal testing.

Ben.

Ben Hutchings (1):
      sfc: Do not use efx_process_channel_now() in online self-test

Neil Turton (2):
      sfc: Stop the TX queues during loopback self-tests
      sfc: Use rmb() to ensure reads occur in order

 drivers/net/sfc/efx.c        |    6 ++++--
 drivers/net/sfc/io.h         |    2 ++
 drivers/net/sfc/net_driver.h |    2 --
 drivers/net/sfc/nic.c        |   22 +++++++++++++++-------
 drivers/net/sfc/nic.h        |    1 +
 drivers/net/sfc/selftest.c   |   25 ++++++-------------------
 drivers/net/sfc/tx.c         |    3 ++-
 7 files changed, 30 insertions(+), 31 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

