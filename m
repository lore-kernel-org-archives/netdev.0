From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/7] be2net: patch set
Date: Fri, 9 May 2014 13:29:12 +0530
Message-ID: <1399622359-25926-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:21308 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbaEIH4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 03:56:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch set contains the following modificatons:
* three patches (1/7 to 3/7) that fix indentation style issues
* convert the u8 vlan[] array to a bit-map to reduce memory usage
* use MCCQ instead of MBOX in be_cmd_rss_config() as the MCCQ is already
  created by that time
* include rx-comp-error counter in ethtool stats
* remove the unused promiscuous setting from be_cmd_vlan_config()

Pls apply to net-next tree. Thanks!

Kalesh AP (3):
  be2net: remove unused code in be_cmd_vlan_config()
  be2net: include rx-compl error counter in ethtool stats
  be2net: use MCCQ instead of MBOX in be_cmd_rss_config()

Ravikumar Nelavelli (1):
  be2net: covert vlan array to bit-map

Sathya Perla (3):
  be2net: fix line wrap and function call indentation in be_main.c
  be2net: fix function call indentation in be_cmds.c
  be2net: fix line wrap and function call indentation in be_ethtool.c

 drivers/net/ethernet/emulex/benet/be.h         |    2 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  365 +++++++++++++-----------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |    2 +-
 drivers/net/ethernet/emulex/benet/be_ethtool.c |  101 +++----
 drivers/net/ethernet/emulex/benet/be_main.c    |  224 +++++++--------
 5 files changed, 346 insertions(+), 348 deletions(-)
