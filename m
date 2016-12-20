From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCHv2 net 0/2] fix the issue that may copy duplicate addrs into assoc's bind address list
Date: Tue, 20 Dec 2016 13:49:48 +0800
Message-ID: <cover.1482212764.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34577 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754058AbcLTFt7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 00:49:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1/2 is to fix some indent level.

Given that we have kernels out there with this issue, patch 2/2 also
fix sctp_raw_to_bind_addrs.

v1 -> v2:
  Explain why we didn't filter the duplicate addresses when global
  address list gets updated in patch 2/2 changelog.

Xin Long (2):
  sctp: reduce indent level in sctp_copy_local_addr_list
  sctp: not copying duplicate addrs to the assoc's bind address list

 net/sctp/bind_addr.c |  3 +++
 net/sctp/protocol.c  | 40 ++++++++++++++++++++++------------------
 2 files changed, 25 insertions(+), 18 deletions(-)

-- 
2.1.0
