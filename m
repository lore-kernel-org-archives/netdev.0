From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/3] smsc95xx enhancements
Date: Wed, 28 Nov 2012 17:46:56 +0000
Message-ID: <1354124819-29531-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:57941 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752324Ab2K1RrE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 12:47:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is a resubmission of 1 updated patch and two new
enhancements.

Please consider all for net-next

Steve Glendinning (3):
  smsc95xx: fix suspend buffer overflow
  smsc95xx: fix error handling in suspend failure case
  smsc95xx: don't enable remote wakeup directly

 drivers/net/usb/smsc95xx.c |   85 ++++++++++++++++++++------------------------
 1 file changed, 39 insertions(+), 46 deletions(-)

-- 
1.7.10.4
