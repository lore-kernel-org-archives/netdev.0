From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/3] fix the transport dead race check by using atomic_add_unless on refcnt
Date: Fri, 22 Jan 2016 01:49:06 +0800
Message-ID: <cover.1453398443.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35043 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755545AbcAURtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 12:49:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Xin Long (3):
  sctp: fix the transport dead race check by using atomic_add_unless on
    refcnt
  sctp: hold transport before we access t->asoc in sctp proc
  sctp: remove the dead field of sctp_transport

 include/net/sctp/structs.h |  5 ++---
 net/sctp/input.c           | 17 +++++++++++------
 net/sctp/proc.c            | 12 ++++++++----
 net/sctp/sm_sideeffect.c   | 12 ------------
 net/sctp/transport.c       |  8 +++-----
 5 files changed, 24 insertions(+), 30 deletions(-)

-- 
2.1.0
