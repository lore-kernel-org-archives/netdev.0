From: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
Subject: [PATCH net-next 0/3] be2net: patch-set
Date: Wed, 13 May 2015 13:00:11 +0530
Message-ID: <1431502214-11810-1-git-send-email-VenkatKumar.Duvvuru@Emulex.com>
Cc: Venkat Duvvuru <VenkatKumar.Duvvuru@Emulex.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:49883 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753703AbbEMHwF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 03:52:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch set has one new feature addition and two fixes.

Patch 1 adds support for hwmon sysfs interface to display board temperature.
Board temperature display through ethtool statistics is removed.

Patch 2 reports "link down" in a few more error cases which are not handled
currently.

Patch 3 adds support for os2bmc. OS2BMC feature will allow the server to
communicate with the on-board BMC/idrac (Baseboard Management Controller)
over the LOM via standard Ethernet. More details are added in the commit log.

Please review.

Venkat Duvvuru (3):
  be2net: Export board temperature using hwmon-sysfs interface.
  be2net: Report a "link down" to the stack when a fatal error or fw
    reset happens.
  be2net: Support for OS2BMC.

 drivers/net/ethernet/emulex/benet/be.h         |   49 ++++--
 drivers/net/ethernet/emulex/benet/be_cmds.c    |   33 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   17 ++
 drivers/net/ethernet/emulex/benet/be_ethtool.c |    1 -
 drivers/net/ethernet/emulex/benet/be_main.c    |  214 +++++++++++++++++++++--
 5 files changed, 276 insertions(+), 38 deletions(-)
