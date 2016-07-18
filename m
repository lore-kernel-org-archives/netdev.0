From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH v5 0/4] Marvell phy: manage fiber link for some phys
Date: Mon, 18 Jul 2016 11:03:39 +0200
Message-ID: <1468832623-1792-1-git-send-email-charles-antoine.couret@nexvision.fr>
Cc: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
To: cacouret.renault@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 9.mo3.mail-out.ovh.net ([87.98.184.141]:36261 "EHLO
	9.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572AbcGRJXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 05:23:51 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id 06F801020B59
	for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 11:04:36 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another patchset to manage correctly the fiber link for some concerned Marvell's
phy like 88E1512.

This patchset fixed the commit log for the second commit and a line from
the first commit moved to the second commit.

Charles-Antoine Couret (4):
  Marvell phy: check link status in case of fiber link.
  Marvell phy: add field to get errors from fiber link.
  Marvell phy: add configuration of autonegociation for fiber link.
  Marvell phy: add functions to suspend and resume both interfaces:    
    fiber and copper links.

 drivers/net/phy/marvell.c | 344 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 327 insertions(+), 17 deletions(-)

-- 
2.7.4
