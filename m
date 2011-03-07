From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 0/7] be2net: Patch series for supporting Lancer
Date: Mon, 7 Mar 2011 18:35:20 +0530
Message-ID: <20cba747-f885-47d5-b27d-788efc426bec@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Subramanian Seetharaman <subbu.seetharaman@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:52312 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751044Ab1CGNGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2011 08:06:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,
	Following are patches to support Lancer family of CNA.
Please apply.
Thanks,
Padmanabh

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Subramanian Seetharaman <subbu.seetharaman@emulex.com>

Padmanabh Ratnakar (7):
  be2net: Remove ERR compl workaround for Lancer
  be2net: Checksum field valid only for TCP/UDP
  be2net: Add error recovery during load for Lancer
  be2net: Change f/w command versions for Lancer
  be2net: Remove TX Queue stop in close
  be2net: Disarm CQ and EQ to disable interrupt in Lancer
  be2net: Add multicast filter capability for Lancer

 drivers/net/benet/be.h      |    4 +-
 drivers/net/benet/be_cmds.c |    8 +++-
 drivers/net/benet/be_cmds.h |    5 +-
 drivers/net/benet/be_hw.h   |   12 ++++
 drivers/net/benet/be_main.c |  118 +++++++++++++++++++++++++++++++------------
 5 files changed, 108 insertions(+), 39 deletions(-)

