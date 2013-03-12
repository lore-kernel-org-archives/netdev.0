From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Pull request: sfc 2013-03-12
Date: Tue, 12 Mar 2013 17:47:25 +0000
Message-ID: <1363110445.2780.14.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>,
	scrum-linux <scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56861 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755039Ab3CLRr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Mar 2013 13:47:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit c80a8512ee3a8e1f7c3704140ea55f21dc6bd651:

  net/core: move vlan_depth out of while loop in skb_network_protocol() (2013-03-12 11:47:40 -0400)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.9

(commit fae8563b25f73dc584a07bcda7a82750ff4f7672)

Just the one bug fix I mentioned before, but it's a pretty important one
as it can cause silent data corruption or IOMMU page faults.

This would be suitable for stable and should apply cleanly to all the
3.x.y branches.  I'm still working through testing of larger sets of
fixes.

Ben.

Ben Hutchings (1):
      sfc: Only use TX push if a single descriptor is to be written

 drivers/net/ethernet/sfc/nic.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
