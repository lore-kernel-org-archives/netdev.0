From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/6] be2net: patch set
Date: Tue, 23 Jul 2013 15:24:58 +0530
Message-ID: <1374573304-6865-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:49011 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755977Ab3GWJvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 05:51:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patches are mostly for providing MAC
filtering ability for VFs. Pls apply. Thanks!

Sathya Perla (6):
  be2net: fix MAC address modification for VF
  be2net: allow VFs to program MAC and VLAN filters
  be2net: fix pmac_id for BE3 VFs
  be2net: refactor MAC-addr setup code
  be2net: use SET/GET_MAC_LIST for SH-R
  be2net: delete primary MAC address while unloading

 drivers/net/ethernet/emulex/benet/be_cmds.c |  116 ++++++++++++++-
 drivers/net/ethernet/emulex/benet/be_cmds.h |   13 ++
 drivers/net/ethernet/emulex/benet/be_main.c |  211 ++++++++++++---------------
 3 files changed, 219 insertions(+), 121 deletions(-)
