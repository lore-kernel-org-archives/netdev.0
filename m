From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net][PATCH v2 0/2] RDS: couple of fixes for 4.6
Date: Thu, 14 Apr 2016 10:43:25 -0700
Message-ID: <1460655807-26236-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:27609 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503AbcDNRnm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 13:43:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v2:
Rebased fixes against 'net' instead of 'net-next' Patches are also
available at below git tree.

The following changes since commit e013b7780c41b471c4269ac9ccafb65ba7c9ec86:

  Merge branch 'dsa-voidify-ops' (2016-04-08 16:51:15 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux.git for_4.6/net/rds-fixes

for you to fetch changes up to e9155afb1902380938ca83ba8504aaa2d7ee5210:

  RDS: Fix the atomicity for congestion map update (2016-04-08 15:08:13 -0700)

----------------------------------------------------------------
Qing Huang (1):
      RDS: fix endianness for dp_ack_seq

Santosh Shilimkar (1):
      RDS: Fix the atomicity for congestion map update

 net/rds/cong.c  | 4 ++--
 net/rds/ib_cm.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

Regards,
Santosh
