From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/7] be2net: patch set
Date: Tue, 11 Mar 2014 18:53:02 +0530
Message-ID: <1394544189-20277-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:37769 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751718AbaCKNTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 09:19:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pls apply. Thanks!

Ravikumar Nelavelli (2):
  be2net: log LPVID used in multi-channel configs
  be2net: fix pmac_id[] allocation size

Sathya Perla (1):
  be2net: update driver version to 10.2

Suresh Reddy (2):
  be2net: Use GET_PROFILE_CONFIG cmd for BE3-R to query max-vfs
  be2net: Add link state control for VFs

Vasundhara Volam (2):
  be2net: Create multiple TXQs on RSS capable multi-channel BE3-R
    interfaces
  be2net: Fix vlans_added counter

 drivers/net/ethernet/emulex/benet/be.h      |    3 +-
 drivers/net/ethernet/emulex/benet/be_cmds.c |   56 +++++++++++++++++++--
 drivers/net/ethernet/emulex/benet/be_cmds.h |   10 ++++
 drivers/net/ethernet/emulex/benet/be_main.c |   73 ++++++++++++++++++++-------
 4 files changed, 118 insertions(+), 24 deletions(-)
