From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 0/2] sctp: a bunch of fixes for processing dupcookie
Date: Tue, 23 May 2017 13:28:53 +0800
Message-ID: <cover.1495517205.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35607 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933158AbdEWF3E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 01:29:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After introducing transport hashtable and per stream info into sctp,
some regressions were caused when processing dupcookie, this patchset
is to fix them.

Xin Long (2):
  sctp: fix stream update when processing dupcookie
  sctp: set new_asoc temp when processing dupcookie

 net/sctp/associola.c     |  4 +++-
 net/sctp/sm_make_chunk.c | 13 ++++---------
 net/sctp/sm_statefuns.c  |  3 +++
 3 files changed, 10 insertions(+), 10 deletions(-)

-- 
2.1.0
