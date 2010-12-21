From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2010-12-21
Date: Tue, 21 Dec 2010 14:46:57 +0000
Message-ID: <1292942817.3256.2.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59270 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751862Ab0LUOrB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 09:47:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit cf78f8ee3de7d8d5b47d371c95716d0e4facf1c4:

  Merge branch 'for-davem' of git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6 (2010-12-10 10:20:43 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem

Some overdue cleanup of the TX path.

Ben.

Ben Hutchings (2):
      sfc: Remove unused field and comment on a previously removed field
      sfc: Remove ancient support for nesting of TX stop

 drivers/net/sfc/efx.c        |   24 +++++----
 drivers/net/sfc/efx.h        |    2 -
 drivers/net/sfc/net_driver.h |   13 +----
 drivers/net/sfc/tx.c         |  111 +++++++----------------------------------
 4 files changed, 35 insertions(+), 115 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


