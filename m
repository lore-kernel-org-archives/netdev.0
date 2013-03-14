From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [net-next 0/2] be2net patch set
Date: Thu, 14 Mar 2013 18:11:32 +0530
Message-ID: <73a526ce-eb3f-43fc-8678-5d524915b7c4@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:1064 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750989Ab3CNMmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Mar 2013 08:42:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply.

Somnath Kotur (2):
  be2net: enable interrupts in be_probe() (RoCE and other ULPs need
    them)
  be2net: Use new F/W mailbox cmd to manipulate interrupts.

 drivers/net/ethernet/emulex/benet/be_cmds.c |   25 +++++++++++++++++
 drivers/net/ethernet/emulex/benet/be_cmds.h |    8 +++++
 drivers/net/ethernet/emulex/benet/be_main.c |   38 ++++++++++++++++----------
 3 files changed, 56 insertions(+), 15 deletions(-)
