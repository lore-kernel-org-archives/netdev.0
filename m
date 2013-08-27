From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH next 0/6] be2net patch set
Date: Tue, 27 Aug 2013 16:57:29 +0530
Message-ID: <1377602855-13920-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:30128 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752072Ab3H0LXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Aug 2013 07:23:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series includes code refactoring patches needed to cleanly implement
ethtool set-channels features. Pls apply. Thanks.

Sathya Perla (5):
  be2net: use EQ_CREATEv2 for SH-R
  be2net: refactor be_get_resources() code
  be2net: Fix be_cmd_if_create() to use MBOX if MCCQ is not created
  be2net: refactor be_setup() to consolidate queue creation routines
  be2net: implement ethtool set/get_channel hooks

Vasundhara Volam (1):
  be2net: Fixup profile management routines

 drivers/net/ethernet/emulex/benet/be.h         |   74 +++-
 drivers/net/ethernet/emulex/benet/be_cmds.c    |  320 +++++++++-------
 drivers/net/ethernet/emulex/benet/be_cmds.h    |   62 ++--
 drivers/net/ethernet/emulex/benet/be_ethtool.c |   25 ++
 drivers/net/ethernet/emulex/benet/be_main.c    |  490 +++++++++++++-----------
 drivers/net/ethernet/emulex/benet/be_roce.c    |    2 +-
 drivers/net/ethernet/emulex/benet/be_roce.h    |    4 +-
 7 files changed, 575 insertions(+), 402 deletions(-)
