From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net-next 0/2] sctp: support MSG_MORE flag when sending msg
Date: Sun, 19 Feb 2017 01:52:44 +0800
Message-ID: <cover.1487440272.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net,
        David Laight <david.laight@aculab.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34349 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753357AbdBRRzS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 12:55:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is to add support for MSG_MORE on sctp. Patch 1/2 is an
improvement ahead of patch 2/2 to solve the close block problem
mentioned in https://patchwork.ozlabs.org/patch/372404/.

Xin Long (2):
  sctp: flush out queue once assoc state falls into SHUTDOWN_PENDING
  sctp: add support for MSG_MORE

 include/net/sctp/structs.h | 1 +
 net/sctp/output.c          | 9 +++------
 net/sctp/sm_sideeffect.c   | 4 ++++
 net/sctp/socket.c          | 1 +
 4 files changed, 9 insertions(+), 6 deletions(-)

-- 
2.1.0
