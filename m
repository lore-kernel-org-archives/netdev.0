From: Mike Maloney <maloneykernel@gmail.com>
Subject: [PATCH net-next 0/2] tcp: Add software rx timestamp for TCP.
Date: Tue, 22 Aug 2017 13:27:01 -0400
Message-ID: <20170822172703.31703-1-maloneykernel@gmail.com>
Cc: Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:34830 "EHLO
        mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbdHVR1R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:27:17 -0400
Received: by mail-yw0-f194.google.com with SMTP id c13so9376285ywa.2
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 10:27:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

Add software rx timestamps for TCP, and a test to ensure consistency of
behavior between IP, UDP, and TCP implementations.

Mike Maloney (2):
  tcp: Extend SOF_TIMESTAMPING_RX_SOFTWARE to TCP recvmsg
  selftests/net: Add a test to validate behavior of rx timestamps

 include/net/tcp.h                                  |   9 +-
 net/ipv4/tcp.c                                     |  63 ++++
 net/ipv4/tcp_input.c                               |  35 +-
 net/ipv4/tcp_ipv4.c                                |   2 +
 net/ipv6/tcp_ipv6.c                                |   2 +
 .../selftests/networking/timestamping/.gitignore   |   1 +
 .../selftests/networking/timestamping/Makefile     |   4 +-
 .../networking/timestamping/rxtimestamp.c          | 379 +++++++++++++++++++++
 8 files changed, 489 insertions(+), 6 deletions(-)
 create mode 100644 tools/testing/selftests/networking/timestamping/rxtimestamp.c

-- 
2.14.1.480.gb18f417b89-goog
