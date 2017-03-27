From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 0/5] rds: trivial patches
Date: Mon, 27 Mar 2017 03:06:25 -0400
Message-ID: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
To: yanjun.zhu@oracle.com, santosh.shilimkar@oracle.com,
        netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        rds-devel@oss.oracle.com, junxiao.bi@oracle.com, joe.jin@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:22535 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdC0HHq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 03:07:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, all 

The 5 patches are trivial patches.

Thanks a lot.

Zhu Yanjun (5):
  rds: tcp: release the created connection
  rds: rdma: fix memory leak error
  rds: remove unnecessary returned value check
  rds: remove the unused variable
  rds: ib: add the static type to the functions

 net/rds/af_rds.c     |  5 +----
 net/rds/ib_mr.h      |  2 --
 net/rds/ib_rdma.c    | 12 +++++-------
 net/rds/ib_recv.c    |  3 +--
 net/rds/rdma.c       |  7 +++++++
 net/rds/rds.h        |  2 +-
 net/rds/stats.c      |  3 +--
 net/rds/tcp_listen.c |  1 +
 8 files changed, 17 insertions(+), 18 deletions(-)

-- 
2.7.4
