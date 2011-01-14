From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-2.6 2011-01-14
Date: Fri, 14 Jan 2011 14:21:29 +0000
Message-ID: <1295014889.5386.1.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:57679 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757697Ab1ANOVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 09:21:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 5b919f833d9d60588d026ad82d17f17e8872c7a9:

  net: ax25: fix information leak to userland harder (2011-01-12 00:34:49 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-2.6.git master

A minor optimisation and a regression fix.

Ben.

Ben Hutchings (2):
      sfc: Make efx_get_tx_queue() an inline function
      sfc: Restore the effect of the rss_cpus module parameter

 drivers/net/sfc/efx.c        |   18 ++++++------------
 drivers/net/sfc/net_driver.h |   10 ++++++++--
 2 files changed, 14 insertions(+), 14 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.



