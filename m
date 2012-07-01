From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH 0/3] net: various tilegx networking fixes
Date: Sun, 1 Jul 2012 14:43:47 -0400
Message-ID: <201207181640.q6IGet7P007227@lab-41.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:32144 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867Ab2GRQk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 12:40:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of fixes corrects a few bugs or style issues observed
in the tilegx network driver.

David, once any potential issues with these patches are resolved,
would you prefer to take them from email, pull them from my net tree,
or have me push them as part of the tile tree?

The tree is at:

  git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git net

Chris Metcalf (3):
      net: tilegx driver bugfix (be explicit about percpu queue number)
      tilegx net driver: handle payload data not in frags
      tilegx net: use eth_hw_addr_random(), not random_ether_addr()

 drivers/net/ethernet/tile/tilegx.c |   61 ++++++++++++++++++++----------------
 1 file changed, 34 insertions(+), 27 deletions(-)

Thanks!
