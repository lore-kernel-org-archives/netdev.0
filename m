From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/7] smsc75xx fixes
Date: Mon, 30 Apr 2012 18:56:49 +0100
Message-ID: <1335808616-22513-1-git-send-email-steve.glendinning@shawell.net>
Cc: David Miller <davem@davemloft.net>,
	Stephane Fillod <fillods@users.sf.net>,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:49410 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754078Ab2D3R5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 13:57:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephane Fillod's big patch addresses multiple issues, so this patchset
splits it into a separate patch for each issue.

Thanks to Stephane for finding and fixing these bugs.

Steve Glendinning (7):
  smsc75xx: mark link down on startup and let PHY interrupt deal with
    carrier changes
  smsc75xx: fix mdio reads and writes
  smsc75xx: add more information to register io failure warnings
  smsc75xx: fix phy init reset loop
  smsc75xx: fix phy interrupt acknowledge
  smsc75xx: declare smsc75xx's MII as GMII capable
  smsc75xx: enable mac to detect speed/duplex from phy

 drivers/net/usb/smsc75xx.c |   35 ++++++++++++++++++++++++-----------
 1 file changed, 24 insertions(+), 11 deletions(-)

-- 
1.7.9.5
