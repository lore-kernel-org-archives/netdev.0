From: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
Subject: [PATCH v6 0/4] Marvell phy: fiber interface configuration
Date: Tue, 19 Jul 2016 11:13:09 +0200
Message-ID: <1468919593-27602-1-git-send-email-charles-antoine.couret@nexvision.fr>
Cc: Charles-Antoine Couret <charles-antoine.couret@nexvision.fr>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 7.mo3.mail-out.ovh.net ([46.105.57.200]:47781 "EHLO
	7.mo3.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335AbcGSJOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 05:14:22 -0400
Received: from player734.ha.ovh.net (b7.ovh.net [213.186.33.57])
	by mo3.mail-out.ovh.net (Postfix) with ESMTP id B0ABDFFCCCD
	for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 11:14:20 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another patchset to manage correctly the fiber link for some concerned Marvell's
phy like 88E1512.

This patchset fixed the commit log for the third and last commits and a comment
in the first commit.

Charles-Antoine Couret (4):
  Marvell phy: check link status in case of fiber link.
  Marvell phy: add field to get errors from fiber link.
  Marvell phy: add configuration of autonegociation for fiber link.
  Marvell phy: add functions to suspend and resume both interfaces:    
    fiber and copper links.

 drivers/net/phy/marvell.c | 346 +++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 328 insertions(+), 18 deletions(-)

-- 
2.7.4
