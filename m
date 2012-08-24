From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc 2012-08-24
Date: Fri, 24 Aug 2012 20:58:45 +0100
Message-ID: <1345838325.2694.41.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:9609 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760169Ab2HXT6t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:58:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 78df76a065ae3b5dbcb9a29912adc02f697de498:

  ipv4: take rt_uncached_lock only if needed (2012-08-24 11:47:48 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.6

(commit ac70b2e9a13423b5efa0178e081936ce6979aea5)

Simple fix for a braino.  Please also queue this for the 3.4 and 3.5
stable series.

Ben.

Ben Hutchings (1):
      sfc: Fix reporting of IPv4 full filters through ethtool

 drivers/net/ethernet/sfc/ethtool.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
