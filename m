From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 0/3] be2net: patch set
Date: Mon, 6 Jan 2014 13:02:22 +0530
Message-ID: <1388993545-25634-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:19240 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810AbaAFH2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 02:28:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply the following bug fixes to the 'net' tree. Thanks.

Suresh Reddy (2):
  be2net: increase the timeout value for loopback-test FW cmd
  be2net: fix max_evt_qs calculation for BE3 in SR-IOV config

Vasundhara Volam (1):
  be2net: disable RSS when number of RXQs is reduced to 1 via
    set-channels

 drivers/net/ethernet/emulex/benet/be.h      |    3 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |   33 ++++++++++++++++++--------
 drivers/net/ethernet/emulex/benet/be_main.c |   29 ++++++++++++++---------
 3 files changed, 43 insertions(+), 22 deletions(-)
