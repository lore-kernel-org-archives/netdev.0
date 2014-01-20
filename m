From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 0/2] sctp: some small clean ups
Date: Mon, 20 Jan 2014 19:27:25 +0800
Message-ID: <1390217247-9408-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:29407 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751947AbaATL2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 06:28:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have the macros in sctp.h, so use them for coding accordance
in sctp.

Wang Weidong (2):
  sctp: use sctp_local_bh_{disable|enable} instead
    local_bh_{disable|enable}
  sctp: use sctp_read_[un]lock instead of read_[un]lock

 net/sctp/endpointola.c   |  4 ++--
 net/sctp/input.c         | 10 +++++-----
 net/sctp/proc.c          | 12 ++++++------
 net/sctp/sm_make_chunk.c |  8 ++++----
 net/sctp/socket.c        |  8 ++++----
 5 files changed, 21 insertions(+), 21 deletions(-)

-- 
1.7.12
