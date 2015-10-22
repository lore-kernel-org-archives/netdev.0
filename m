From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH v2 0/2] mvneta ethtool statistics
Date: Thu, 22 Oct 2015 18:00:13 +0100
Message-ID: <20151022170013.GV32532@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>, Marcin Wojtas <mw@semihalf.com>,
	netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:56463 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965181AbbJVRAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 13:00:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This short series adds ethtool statistics reporting to mvneta.  Having
discussed with Andrew on IRC, we decided I'd pick up his patch into my
series.

My change for patch 1 compared to the previous RFC splits out the
reading of the statistics from the hardware into a separate function,
in order to facilitate work going on elsewhere to arrange for the
statistics to be preserved across a suspend/resume cycle.

 drivers/net/ethernet/marvell/mvneta.c | 117 +++++++++++++++++++++++++++++++++-
 1 file changed, 115 insertions(+), 2 deletions(-)

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
