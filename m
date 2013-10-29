From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH v3 0/4] Fix MDIO bus timeout issues on Dreamplug
Date: Tue, 29 Oct 2013 09:33:30 +0000
Message-ID: <cover.1383038973.git.leigh@solinno.co.uk>
References: <cover.1382637156.git.leigh@solinno.co.uk>
Cc: Leigh Brown <leigh@solinno.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:58151 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab3J2JeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 05:34:02 -0400
In-Reply-To: <cover.1382637156.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I think I have addressed all comments.

Changes since v2:
 - Fix coding style in ordio_mdio_wait_ready, as identified by David
 - Remove un-needed operator change in orion_mdio_write, as identified by David

This patchset fixes an issue with the Dreamplug MDIO bus timeout since the
mv643xx_eth driver was converted to use the mvmdio driver to access the bus.

Leigh Brown (4):
  net: mvmdio: make orion_mdio_wait_ready consistent
  net: mvmdio: orion_mdio_ready: remove manual poll
  net: mvmdio: slight optimisation of orion_mdio_write
  net: mvmdio: doc: mvmdio now used by mv643xx_eth

 drivers/net/ethernet/marvell/mvmdio.c | 110 ++++++++++++++++------------------
 1 file changed, 53 insertions(+), 57 deletions(-)

-- 
1.8.4.rc3
