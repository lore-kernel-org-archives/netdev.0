From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [GIT PULL] Marvell mvneta Ethernet/MDIO drivers checkpatch fixes
Date: Mon, 19 Nov 2012 12:00:31 +0100
Message-ID: <1353322834-16952-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>, netdev@vger.kernel.org
To: Jason Cooper <jason@lakedaemon.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([88.190.12.23]:35937 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751459Ab2KSLAw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2012 06:00:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jason,

Sebastian Hesselbarth noticed that the new mvmdio and mvneta drivers
produce a number of checkpatch warnings, related to the incluse of
<asm/delay.h> and to the style of multiline comments. The following
three patches fix those checkpatch warnings. Feel free to integrate
them either as follow-up patches of the network driver patches, or to
squash them into the driver patches as you prefer.

David, are you OK with those patches and the fact that we carry them
through the arm-soc tree, as we agreed to do for the mvmdio and mvneta
drivers? Those patches are really simple/stupid fixes.

Thanks!

The following changes since commit a7e7265b086fb12eb4472d0d216c6b787bb35eba:

  Merge remote-tracking branch 'jcooper/mvebu/dt' into mvneta-fixes (2012-11-19 11:30:18 +0100)

are available in the git repository at:


  git@github.com:MISL-EBU-System-SW/mainline-public.git tags/marvell-net-mdio-checkpatch-fixes-3.8

for you to fetch changes up to e313b995bf8598f56c98377a750f968f9dd5ca78:

  net: mvneta: adjust multiline comments to net/ style (2012-11-19 11:42:42 +0100)

----------------------------------------------------------------
Marvell network/MDIO driver checkpatch fixes

----------------------------------------------------------------
Thomas Petazzoni (3):
      net: mvmdio: use <linux/delay.h> instead of <asm/delay.h>
      net: mvmdio: adjust multiline comment to net/ style
      net: mvneta: adjust multiline comments to net/ style

 drivers/net/ethernet/marvell/mvmdio.c |    6 +--
 drivers/net/ethernet/marvell/mvneta.c |   84 ++++++++++++++++-----------------
 2 files changed, 44 insertions(+), 46 deletions(-)
