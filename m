From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/6] smsc95xx enhancements (V3)
Date: Fri, 28 Sep 2012 11:07:06 +0100
Message-ID: <1348826832-1986-1-git-send-email-steve.glendinning@shawell.net>
Cc: Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:45957 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138Ab2I1KHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 06:07:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset makes a few minor enhancements to the smsc95xx driver
including improved power saving during suspend and support for
magic packet wol.

Please consider all for net-next.

Changes since v2:
 remove use of BUG_ON, replace with WARN_ON_ONCE

Changes since v1:
 remove duplicate .suspend and .resume entries

Steve Glendinning (6):
  smsc95xx: sleep before read for lengthy operations
  smsc95xx: remove unnecessary variables
  smsc95xx: check return code from control messages
  smsc95xx: fix resume when usb device is reset
  smsc95xx: enable power saving mode during system suspend
  smsc95xx: add wol magic packet support

 drivers/net/usb/smsc95xx.c |  560 ++++++++++++++++++++++++++++----------------
 drivers/net/usb/smsc95xx.h |   12 +-
 2 files changed, 366 insertions(+), 206 deletions(-)

-- 
1.7.9.5
