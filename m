From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH v2 0/3] sctp: do some clean up and fix comments
Date: Sat, 26 Oct 2013 16:06:29 +0800
Message-ID: <1382774792-13440-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <dingtianhong@huawei.com>,
	<linux-sctp@vger.kernel.org>, <netdev@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:25455 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752249Ab3JZIHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Oct 2013 04:07:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series includes some comments fix, merge tow if-statements,
remove the repeat initialize with 0.

v1 -> v2:
  - patch1: combine two comment typos fix patches into one,
    as suggested by Vlad, and add his ACK.
  - patch2: add Vlad's ACK.
  - patch3: line up 2 parts of 'if' statements, as suggested by Vlad.
    fix some comment typos, as suggested by Sergei.

Wang Weidong (3):
  sctp: fix some comments in chunk.c and associola.c
  sctp: remove the repeat initialize with 0
  sctp: merge two if statements to one

 net/sctp/associola.c     |  4 ++--
 net/sctp/auth.c          | 14 +++++---------
 net/sctp/chunk.c         |  2 +-
 net/sctp/sm_make_chunk.c | 29 ++++++++---------------------
 4 files changed, 16 insertions(+), 33 deletions(-)

-- 
1.7.12
