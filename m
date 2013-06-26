From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] Rework SCTP debugging framework
Date: Wed, 26 Jun 2013 19:01:11 +0200
Message-ID: <1372266073-11998-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34786 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751285Ab3FZRBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 13:01:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please see patch 2 for a detailed description. Tested with lksctp-tools
suite and other stress tests.

Daniel Borkmann (2):
  lib: vsprintf: add IPv4/v6 generic %pig/%pIg format specifier
  net: sctp: rework debugging framework to use pr_debug and friends

 include/net/sctp/sctp.h  |  75 ---------------------
 lib/vsprintf.c           |  18 ++++-
 net/sctp/Kconfig         |  12 ++--
 net/sctp/associola.c     |  69 +++++++++----------
 net/sctp/chunk.c         |   5 +-
 net/sctp/debug.c         |   4 --
 net/sctp/endpointola.c   |   5 +-
 net/sctp/input.c         |   6 +-
 net/sctp/inqueue.c       |   9 ++-
 net/sctp/ipv6.c          |  21 +++---
 net/sctp/output.c        |  40 +++++------
 net/sctp/outqueue.c      | 160 ++++++++++++++++++++------------------------
 net/sctp/protocol.c      |  48 +++++++-------
 net/sctp/sm_make_chunk.c |  25 +++----
 net/sctp/sm_sideeffect.c |  97 ++++++++++++---------------
 net/sctp/sm_statefuns.c  |  77 +++++++++++++---------
 net/sctp/socket.c        | 168 ++++++++++++++++++++++-------------------------
 net/sctp/transport.c     |  51 +++++++-------
 18 files changed, 405 insertions(+), 485 deletions(-)

-- 
1.7.11.7
