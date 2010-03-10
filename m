From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 0/6] smsc95xx: minor fixes and tidy-ups
Date: Wed, 10 Mar 2010 18:32:33 +0000
Message-ID: <1268245959-13861-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:41121 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932694Ab0CJSck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:32:40 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id DA1CC67BC8
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:32:39 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset contains minor bugfixes and tidy-ups to the smsc95xx
driver.  Please consider for net-next.

Steve Glendinning (6):
  smsc95xx: change hard_header_len to include csum offload bytes
  smsc95xx: wait for PHY to complete reset during init
  smsc95xx: add constant definition for SMSC USB vendor id
  smsc95xx: sleep before read for lengthy operations
  smsc95xx: check return code from control messages
  smsc95xx: remove unnecessary variables

 drivers/net/usb/smsc95xx.c |  379 ++++++++++++++++++++------------------------
 drivers/net/usb/smsc95xx.h |    1 +
 2 files changed, 170 insertions(+), 210 deletions(-)

