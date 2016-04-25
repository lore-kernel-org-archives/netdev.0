From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 0/2] net: avoid some atomic ops when FASYNC is not used
Date: Mon, 25 Apr 2016 10:39:31 -0700
Message-ID: <1461605974-4242-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33693 "EHLO
	mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932191AbcDYRjr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 13:39:47 -0400
Received: by mail-pf0-f182.google.com with SMTP id 206so20090042pfu.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 10:39:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can avoid some atomic operations on sockets not using FASYNC

Eric Dumazet (2):
  net: SOCKWQ_ASYNC_NOSPACE optimizations
  net: SOCKWQ_ASYNC_WAITDATA optimizations

 include/net/sock.h | 8 ++++++++
 1 file changed, 8 insertions(+)

-- 
2.8.0.rc3.226.g39d4020
