From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc-next 2013-11-01
Date: Sat, 2 Nov 2013 01:37:46 +0000
Message-ID: <1383356266.1737.42.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:60185 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752718Ab3KBBhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Nov 2013 21:37:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit ba4865027c11d7ac8e5a33e0624dd415caab2027:

  ipv6: remove the unnecessary statement in find_match() (2013-10-30 17:06:51 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next.git for-davem

for you to fetch changes up to 2acdb92e85412bf791a3c01f2173695b6e0a3f72:

  sfc: Fix DMA unmapping issue with firmware assisted TSO (2013-10-31 20:58:14 +0000)

A single fix by Alexandre Rames for the recent changes to TSO.

Ben.

----------------------------------------------------------------
Alexandre Rames (1):
      sfc: Fix DMA unmapping issue with firmware assisted TSO

 drivers/net/ethernet/sfc/net_driver.h | 3 +++
 drivers/net/ethernet/sfc/tx.c         | 7 +++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
