From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 0/2] be2net: patch set
Date: Tue, 15 Oct 2013 17:21:09 +0530
Message-ID: <1381837869-9543-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:26147 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750904Ab3JOLrP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 07:47:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply the following fixes to the net tree. Thanks.

Vasundhara Volam (2):
  be2net: pass if_id for v1 and V2 versions of TX_CREATE cmd
  be2net: drop non-tso frames longer than mtu

 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 ++-
 drivers/net/ethernet/emulex/benet/be_main.c |    9 +++++++--
 2 files changed, 9 insertions(+), 3 deletions(-)
