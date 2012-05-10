From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc 2012-05-09
Date: Thu, 10 May 2012 03:06:35 +0100
Message-ID: <1336615595.2499.24.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:7521 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751547Ab2EJCGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2012 22:06:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 477206a018f902895bfcd069dd820bfe94c187b1:

  r8169: fix unsigned int wraparound with TSO (2012-05-08 19:34:10 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.4

(commit 3132d2827d92c2ee47fdf4dbec75bba0a2f291cb)

This fixes a regression introduced since Linux 3.3 which will result in
a crash on load in certain configurations.

Ben.

Ben Hutchings (1):
      sfc: Fix division by zero when using one RX channel and no SR-IOV

 drivers/net/ethernet/sfc/efx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
