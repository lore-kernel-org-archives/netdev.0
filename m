From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/6] smsc75xx enhancements
Date: Wed, 28 Nov 2012 15:59:44 +0000
Message-ID: <1354118391-22666-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57251 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab2K1P77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 10:59:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements wake on PHY (link up or link down) and
USB dynamic autosuspend for smsc75xx.

Please consider all for net-next.

Steve Glendinning (6):
  smsc75xx: check return code from smsc75xx_reset
  smsc75xx: refactor entering suspend modes
  smsc75xx: support PHY wakeup source
  smsc75xx: fix error handling in suspend failure case
  smsc75xx: add support for USB dynamic autosuspend
  smsc75xx: don't enable remote wakeup directly

 drivers/net/usb/smsc75xx.c |  415 +++++++++++++++++++++++++++++++++++---------
 1 file changed, 330 insertions(+), 85 deletions(-)

-- 
1.7.10.4
