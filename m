From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/4] smsc75xx: enhancements (V2)
Date: Fri, 28 Sep 2012 11:57:49 +0100
Message-ID: <1348829873-30779-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:46291 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757247Ab2I1K6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 06:58:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes a few enhancements to the smsc75xx driver
including improved power saving during suspend and support for
magic packet wol.

This patchset has been rebased against net-next/master but I
believe the first patch has already been included in net/master.

Steve Glendinning (4):
  smsc75xx: fix resume after device reset
  smsc75xx: add explicit test that device is READY
  smsc75xx: enable power saving mode during system suspend
  smsc75xx: add wol magic packet support

 drivers/net/usb/smsc75xx.c |  239 +++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 237 insertions(+), 2 deletions(-)

-- 
1.7.9.5
