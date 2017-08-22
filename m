From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next v3 0/2] Simplify the tcp_conn_request.
Date: Mon, 21 Aug 2017 23:33:47 -0700
Message-ID: <1503383629-12392-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: eric.dumazet@gmail.com, Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35099 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754433AbdHVGeH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 02:34:07 -0400
Received: by mail-pg0-f67.google.com with SMTP id m133so7274213pga.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 23:34:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just simplify the tcp_conn_request function.

Tonghao Zhang (2):
  tcp: Get a proper dst before checking it.
  tcp: Remove the unused parameter for tcp_try_fastopen.

 include/net/tcp.h       |  3 +--
 net/ipv4/tcp_fastopen.c |  6 ++----
 net/ipv4/tcp_input.c    | 11 +++++------
 3 files changed, 8 insertions(+), 12 deletions(-)

-- 
2.13.4
