From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc 2013-03-06
Date: Wed, 6 Mar 2013 19:14:21 +0000
Message-ID: <1362597261.3126.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	scrum-linux <scrum-linux@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52360 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223Ab3CFTOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:14:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit aab2b4bf224ef8358d262f95b568b8ad0cecf0a0:

  tcp: fix double-counted receiver RTT when leaving receiver fast path (2013-03-04 14:12:07 -0500)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.9

Fix regressions introduced by the last set of fixes (sorry):

1. Potential deadlock when disabling TX queues.
2. RX was broken on architectures other than x86 and powerpc.

I still expect to send one more bug fix for 3.9, but as it sometimes
takes days to reproduce the bug it's going to take a couple of weeks of
testing to be confident that it's really fixed.

Ben.

Ben Hutchings (2):
      sfc: Disable soft interrupt handling during efx_device_detach_sync()
      sfc: Correct efx_rx_buffer::page_offset when EFX_PAGE_IP_ALIGN != 0

 drivers/net/ethernet/sfc/efx.h |    4 ++--
 drivers/net/ethernet/sfc/rx.c  |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
