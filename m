From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 0/5] be2net: patch series
Date: Tue, 10 May 2011 20:42:00 +0530
Message-ID: <63728a21-82b6-4233-9051-af735cd6c5c3@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:11240 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751489Ab1EJPNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 11:13:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please apply.
Thanks,
Padmanabh

Padmanabh Ratnakar (5):
  be2net: Handle error completion in Lancer
  be2net: Disable coalesce water mark mode of CQ for Lancer
  be2net: be2net: In case of UE, do not dump registers for Lancer
  be2net: Use NTWK_RX_FILTER command for promiscous mode
  be2net: Fix to prevent flooding of TX queue

 drivers/net/benet/be_cmds.c |   51 +++++++++++++++++++++++++++---------------
 drivers/net/benet/be_cmds.h |   24 ++++++++++++-------
 drivers/net/benet/be_main.c |   29 +++++++++++++++---------
 3 files changed, 66 insertions(+), 38 deletions(-)

