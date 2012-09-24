From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/5] smsc95xx enhancements
Date: Mon, 24 Sep 2012 15:40:49 +0100
Message-ID: <1348497654-9915-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:37775 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756169Ab2IXOu0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 10:50:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes a few minor enhancements to the smsc95xx driver
in preparation for some forthcoming power-saving improvements I'm
working on.

Please consider all for net-next.

Steve Glendinning (5):
  smsc95xx: sleep before read for lengthy operations
  smsc95xx: remove unnecessary variables
  smsc95xx: check return code from control messages
  smsc95xx: fix resume when usb device is reset
  smsc95xx: enable power saving mode during system suspend

 drivers/net/usb/smsc95xx.c |  389 +++++++++++++++++++++-----------------------
 drivers/net/usb/smsc95xx.h |    7 +-
 2 files changed, 192 insertions(+), 204 deletions(-)

-- 
1.7.9.5
