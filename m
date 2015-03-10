From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/3] inet_diag: cleanups and improvements
Date: Tue, 10 Mar 2015 07:15:51 -0700
Message-ID: <1425996954-24693-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f74.google.com ([209.85.213.74]:33619 "EHLO
	mail-yh0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751467AbbCJOQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 10:16:08 -0400
Received: by yhoa41 with SMTP id a41so293814yho.0
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 07:16:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before changing way request socks are dumped, let's clean up this code
a bit.

Eric Dumazet (3):
  net: constify sock_diag_check_cookie()
  inet_diag: cleanups
  inet_diag: add const to inet_diag_req_v2

 include/linux/inet_diag.h |  43 ++++++-------
 include/linux/sock_diag.h |   2 +-
 net/core/sock_diag.c      |   2 +-
 net/dccp/diag.c           |   7 ++-
 net/ipv4/inet_diag.c      | 154 +++++++++++++++++++++++-----------------------
 net/ipv4/tcp_diag.c       |   4 +-
 net/ipv4/udp_diag.c       |  22 ++++---
 7 files changed, 119 insertions(+), 115 deletions(-)

-- 
2.2.0.rc0.207.ga3a616c
