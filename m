From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 0/2] be2net: patch set
Date: Mon, 18 Mar 2013 12:33:55 +0530
Message-ID: <bfd8205d-1c91-4947-88f7-c27554b4dd06@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:54097 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751130Ab3CRHFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Mar 2013 03:05:03 -0400
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
