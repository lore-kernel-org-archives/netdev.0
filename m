From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/5] smsc95xx enhancements (v2)
Date: Wed, 26 Sep 2012 13:40:19 +0100
Message-ID: <1348663224-30403-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:56604 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752879Ab2IZMk1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 08:40:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes a few minor enhancements to the smsc95xx driver
in preparation for some forthcoming power-saving improvements I'm
working on.

Please consider all for net-next.

Changes since v1:
 remove duplicate .suspend and .resume entries

Steve Glendinning (5):
  smsc95xx: sleep before read for lengthy operations
  smsc95xx: remove unnecessary variables
  smsc95xx: check return code from control messages
  smsc95xx: fix resume when usb device is reset
  smsc95xx: enable power saving mode during system suspend

 drivers/net/usb/smsc95xx.c |  388 +++++++++++++++++++++-----------------------
 drivers/net/usb/smsc95xx.h |    7 +-
 2 files changed, 190 insertions(+), 205 deletions(-)

-- 
1.7.9.5
