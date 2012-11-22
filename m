From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/5] smsc95xx updates
Date: Thu, 22 Nov 2012 18:05:21 +0000
Message-ID: <1353607526-19307-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:59734 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab2KVSfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Nov 2012 13:35:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset contains all my pending smsc95xx development patches.

please consider 1 - 4 for net-next.

1 is a bugfix so please also consider it for net and stable.

5 is for review and comment only, it's not ready for inclusion yet.

Thanks,

Steve Glendinning (5):
  smsc95xx: fix error checking of usbnet_resume
  smsc95xx: detect chip revision specific features
  smsc95xx: support PHY wakeup source
  smsc95xx: refactor entering suspend modes
  smsc95xx: enable dynamic autosuspend (RFC)

 drivers/net/usb/smsc95xx.c |  405 +++++++++++++++++++++++++++++++++++++-------
 drivers/net/usb/smsc95xx.h |   20 +++
 2 files changed, 363 insertions(+), 62 deletions(-)

-- 
1.7.10.4
