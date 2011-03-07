From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2011-03-07
Date: Mon, 07 Mar 2011 23:23:14 +0000
Message-ID: <1299540194.2522.46.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sf-linux-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3390 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755982Ab1CGXXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 18:23:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 07df5294a753dfac2cc9f75e6159fc25fdc22149:

  inet: Replace left-over references to inet->cork (2011-03-01 23:00:58 -0800)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem

Just one more performance optimisation.

Ben.

Ben Hutchings (1):
      sfc: Use write-combining to reduce TX latency

 drivers/net/sfc/efx.c  |    4 ++--
 drivers/net/sfc/io.h   |   13 +++++++++----
 drivers/net/sfc/mcdi.c |    9 +++++----
 3 files changed, 16 insertions(+), 10 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

