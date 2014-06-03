From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH 0/3 v2] cnic fixes.
Date: Mon, 2 Jun 2014 23:08:45 -0700
Message-ID: <1401775728-21043-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <nhorman@tuxdriver.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:24292 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088AbaFCEsL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 00:48:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix 2 sleeping function from invalid context bugs and 1 missing iscsi netlink
message bug.

v2: Fixed typo in rcu_dereference_protected() and tested with CONFIG_PROVE_RCU

Michael Chan (3):
  cnic: Don't take rcu_read_lock in cnic_rcv_netevent()
  cnic: Don't take cnic_dev_lock in cnic_alloc_uio_rings()
  cnic: Fix missing ISCSI_KEVENT_IF_DOWN message

 drivers/net/ethernet/broadcom/cnic.c |   29 ++++++++++++++++-------------
 1 files changed, 16 insertions(+), 13 deletions(-)
