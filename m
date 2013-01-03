From: Steve Glendinning <steve.glendinning@shawell.net>
Subject: [PATCH 0/2] smsc95xx enhancements
Date: Thu,  3 Jan 2013 13:00:14 +0000
Message-ID: <1357218016-2586-1-git-send-email-steve.glendinning@shawell.net>
Cc: ming.lei@canonical.com, oneukum@suse.de,
	gregkh@linuxfoundation.org,
	Steve Glendinning <steve.glendinning@shawell.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cust23-dsl91-135-1.idnet.net ([91.135.1.23]:38667 "EHLO
	drevil.shawell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753059Ab3ACNAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 08:00:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Two driver enhancements for net-next.  There's ongoing discussion around
the best way to improve autosuspend moving forwards but in the meantime
the second patch in this set enables autosuspend for supported parts in
most situations.

Steve Glendinning (2):
  smsc95xx: eliminate duplicate warnings on io failure
  smsc95xx: enable dynamic autosuspend

 drivers/net/usb/smsc95xx.c |  435 ++++++++++++++++++++++----------------------
 1 file changed, 217 insertions(+), 218 deletions(-)

-- 
1.7.10.4
