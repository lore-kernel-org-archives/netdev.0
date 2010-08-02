From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 0/2] Minor extensions to marvell phy driver
Date: Mon,  2 Aug 2010 15:44:52 -0400
Message-ID: <1280778294-2993-1-git-send-email-cyril@ti.com>
Cc: Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:35663 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754568Ab0HBTo6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Aug 2010 15:44:58 -0400
Received: from dlep36.itg.ti.com ([157.170.170.91])
	by comal.ext.ti.com (8.13.7/8.13.7) with ESMTP id o72JiwjX003213
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 2 Aug 2010 14:44:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds a couple of minor extensions to the marvell phy driver.
The first patch in the series allows for RGMII TX and RX delay configuration
via interface mode.  The second patch adds support for a new device (88ec048).

Cyril Chemparathy (2):
  phy/marvell: add 88e1121 interface mode support
  phy/marvell: add 88ec048 support

 drivers/net/phy/marvell.c |   76 +++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 73 insertions(+), 3 deletions(-)

