From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v5 0/2] sctp: check the rto_min and rto_max
Date: Sat, 7 Dec 2013 15:17:29 +0800
Message-ID: <1386400651-21744-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:59518 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396Ab3LGHSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Dec 2013 02:18:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

v4 -> v5
  - patch1: add marco in constants.h and fix up spacing as
    suggested by Daniel
  - patch2: add a patch for fix up do_hmac_alg for according
    to do_rto_min[max]

Wang Weidong (2):
  sctp: check the rto_min and rto_max
  sctp: fix up a spacing

 include/net/sctp/constants.h |  3 ++
 net/sctp/socket.c            |  5 +++
 net/sctp/sysctl.c            | 80 ++++++++++++++++++++++++++++++++++++++------
 3 files changed, 77 insertions(+), 11 deletions(-)

-- 
1.7.12
