From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-2.6 2011-05-12
Date: Thu, 12 May 2011 17:07:08 +0100
Message-ID: <1305216428.5214.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:13494 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757918Ab1ELQHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 May 2011 12:07:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit ff538818f4a82c4cf02d2d6bd6ac5c7360b9d41d:

  sysctl: net: call unregister_net_sysctl_table where needed (2011-05-02 16:12:14 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-2.6.git sfc-2.6.39

Ben Hutchings (1):
      sfc: Always map MCDI shared memory as uncacheable

Sorry for sending this so late.  I was really hoping to get to the
bottom of this issue and find a simple fix.

Ben.

 drivers/net/sfc/mcdi.c  |   49 ++++++++++++++++++++++++++++------------------
 drivers/net/sfc/nic.h   |    2 +
 drivers/net/sfc/siena.c |   25 ++++++++++++++++++++---
 3 files changed, 53 insertions(+), 23 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

