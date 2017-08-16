From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH net-next v2 0/2] simplify the tcp_conn_request.
Date: Wed, 16 Aug 2017 08:28:34 -0700
Message-ID: <1502897316-3666-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37905 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751531AbdHPP3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 11:29:00 -0400
Received: by mail-pg0-f65.google.com with SMTP id 123so5486089pga.5
        for <netdev@vger.kernel.org>; Wed, 16 Aug 2017 08:28:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches are not bugfix. But just simplify the tcp_conn_request
function.

These patches are based on Davem's net-next tree.

Tonghao Zhang (2):
  tcp: Remove unnecessary dst check in tcp_conn_request.
  tcp: Remove the unused parameter for tcp_try_fastopen.

 include/net/tcp.h       |  3 +--
 net/ipv4/tcp_fastopen.c |  6 ++----
 net/ipv4/tcp_input.c    | 11 +++++------
 3 files changed, 8 insertions(+), 12 deletions(-)

-- 
1.8.3.1
