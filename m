From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/2] smsc75xx enhancements
Date: Fri, 30 Nov 2012 14:52:42 +0000
Message-ID: <1354287164-9884-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47297 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755498Ab2K3Ows (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 09:52:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset, as requestes, expands the macros used in
smsc75xx to make the flow control clearer.

I've left the fix in a separate patch, so the macro-
expanding patch should have zero functional change.

Steve Glendinning (2):
  smsc75xx: don't call usbnet_resume if usbnet_suspend fails
  smsc75xx: expand check_ macros

 drivers/net/usb/smsc75xx.c |  735 ++++++++++++++++++++++++++++++++++----------
 1 file changed, 576 insertions(+), 159 deletions(-)

-- 
1.7.10.4
