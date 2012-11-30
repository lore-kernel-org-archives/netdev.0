From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/5] smsc95xx enhancements
Date: Fri, 30 Nov 2012 15:55:47 +0000
Message-ID: <1354290952-27109-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:47837 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030928Ab2K3Pz4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 10:55:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is a resubmission of several patches plus two new
patches, including the expansion of cpp macros at the request of
davem.

Steve Glendinning (5):
  smsc95xx: fix suspend buffer overflow
  smsc95xx: fix error handling in suspend failure case
  smsc95xx: don't enable remote wakeup directly
  smsc95xx: fix smsc_crc return type
  smsc95xx: expand check_ macros

 drivers/net/usb/smsc95xx.c |  566 ++++++++++++++++++++++++++++++++------------
 1 file changed, 415 insertions(+), 151 deletions(-)

-- 
1.7.10.4
