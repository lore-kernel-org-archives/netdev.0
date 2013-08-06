From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/7] be2net patch set
Date: Tue, 6 Aug 2013 09:27:14 +0530
Message-ID: <1375761441-22343-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:38606 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab3HFDxn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 23:53:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following fix/cleanup patches are for the net-next tree. Pls apply.

Thanks!

Sathya Perla (1):
  be2net: update driver version

Vasundhara Volam (6):
  be2net: Adding more speeds reported by get_settings
  be2net: Do not call get_die_temperature cmd for VF
  be2net: don't limit max MAC and VLAN counts
  be2net: Fix displaying supported speeds for BE2
  be2net: fixup log msgs for async events
  be2net: Initialize "status" in be_cmd_get_die_temperature()

 drivers/net/ethernet/emulex/benet/be.h      |    2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |   20 +++++++++++++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h |    5 ++++-
 drivers/net/ethernet/emulex/benet/be_main.c |   10 ++--------
 4 files changed, 24 insertions(+), 13 deletions(-)
