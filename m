From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/3] sctp: some cleanups for sctp
Date: Mon, 15 Feb 2016 14:28:02 +0800
Message-ID: <cover.1455517541.git.lucien.xin@gmail.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:34766 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbcBOG2L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 01:28:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some unused function and redundant rcu locks should be
removed.

Xin Long (3):
  sctp: move rcu_read_lock from __sctp_lookup_association to
    sctp_lookup_association
  sctp: remove rcu_read_lock in sctp_seq_dump_remote_addrs()
  sctp: remove the unused sctp_datamsg_free()

 include/net/sctp/structs.h |  1 -
 net/sctp/chunk.c           | 13 -------------
 net/sctp/input.c           |  4 ++--
 net/sctp/proc.c            |  2 --
 4 files changed, 2 insertions(+), 18 deletions(-)

-- 
2.1.0
