From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/2] smsc75xx enhancements
Date: Tue, 27 Nov 2012 14:28:00 +0000
Message-ID: <1354026482-10443-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47515 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab2K0O2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 09:28:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset implements wake on PHY (link up or link down) for
smsc75xx, please consider for net-next.

Steve Glendinning (2):
  smsc75xx: refactor entering suspend modes
  smsc75xx: support PHY wakeup source

 drivers/net/usb/smsc75xx.c |  224 ++++++++++++++++++++++++++++++++++++--------
 1 file changed, 186 insertions(+), 38 deletions(-)

-- 
1.7.10.4
