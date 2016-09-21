From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH next v3 0/2] Rename WORD_TRUNC/ROUND macros and use them
Date: Wed, 21 Sep 2016 08:45:54 -0300
Message-ID: <cover.1474457954.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        David Miller <davem@davemloft.net>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45578 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933502AbcIULqF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Sep 2016 07:46:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset aims to rename these macros to a non-confusing name, as
reported by David Laight and David Miller, and to update all remaining
places to make use of it, which was 1 last remaining spot.

v3:
- Name it SCTP_PAD4 instead of SCTP_ALIGN4, as suggested by David Laight
v2:
- fixed 2nd patch summary

Details on the specific changelogs.

Thanks!

Marcelo Ricardo Leitner (2):
  sctp: rename WORD_TRUNC/ROUND macros
  sctp: make use of WORD_TRUNC macro

 include/net/sctp/sctp.h  | 10 +++++-----
 net/netfilter/xt_sctp.c  |  2 +-
 net/sctp/associola.c     |  2 +-
 net/sctp/chunk.c         | 13 +++++++------
 net/sctp/input.c         |  8 ++++----
 net/sctp/inqueue.c       |  2 +-
 net/sctp/output.c        | 12 ++++++------
 net/sctp/sm_make_chunk.c | 28 ++++++++++++++--------------
 net/sctp/sm_statefuns.c  |  6 +++---
 net/sctp/transport.c     |  4 ++--
 net/sctp/ulpevent.c      |  4 ++--
 11 files changed, 46 insertions(+), 45 deletions(-)

-- 
2.7.4
