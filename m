From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/2] sctp: not copying duplicate addrs to the assoc's bind address list
Date: Fri, 19 Aug 2016 19:30:20 +0800
Message-ID: <cover.1471605833.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36613 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750889AbcHSMTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 08:19:54 -0400
Received: by mail-pf0-f196.google.com with SMTP id y134so1419352pfg.3
        for <netdev@vger.kernel.org>; Fri, 19 Aug 2016 05:19:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patch 1/2 is to fix some indent level.

Given that we have kernels out there with this issue, patch 2/2 also
fix sctp_raw_to_bind_addrs.

Xin Long (2):
  sctp: reduce indent level in sctp_copy_local_addr_list
  sctp: not copying duplicate addrs to the assoc's bind address list

 net/sctp/bind_addr.c |  3 +++
 net/sctp/protocol.c  | 40 ++++++++++++++++++++++------------------
 2 files changed, 25 insertions(+), 18 deletions(-)

-- 
2.1.0
