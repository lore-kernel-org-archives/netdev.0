From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v7 0/3] sctp: check the rto_min and rto_max
Date: Wed, 11 Dec 2013 09:50:37 +0800
Message-ID: <1386726640-9584-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:3640 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849Ab3LKBvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 20:51:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v6 -> v7:
  -patch2: fix the whitespace issues which pointed out by Daniel

v5 -> v6:
  split the v5' first patch to patch1 and patch2, and remove the
  macro in constants.h

  -patch1: do rto_min/max socket option handling in its own patch, and
   fix the check of rto_min/max.
  -patch2: do rto_min/max sysctl handling in its own patch.
  -patch3: add Suggested-by Daniel.

v4 -> v5:
  - patch1: add marco in constants.h and fix up spacing as
    suggested by Daniel
  - patch2: add a patch for fix up do_hmac_alg for according
    to do_rto_min[max]

v3 -> v4:
  -patch1: fix use init_net directly which suggested by Vlad.

v2 -> v3:
  -patch1: add proc_handler for check rto_min and rto_max which suggested
   by Vlad

v1 -> v2:
  -patch1: fix the From Name which pointed out by David, and
   add the ACK by Neil

Wang Weidong (3):
  sctp: check the rto_min and rto_max in setsockopt
  sctp: add check rto_min and rto_max in sysctl
  sctp: fix up a spacing

 net/sctp/socket.c | 32 +++++++++++++++--------
 net/sctp/sysctl.c | 76 ++++++++++++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 89 insertions(+), 19 deletions(-)

-- 
1.7.12
