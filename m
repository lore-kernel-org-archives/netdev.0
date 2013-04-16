From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/9] Minor SCTP cleanups all over the place
Date: Tue, 16 Apr 2013 23:07:09 +0200
Message-ID: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28144 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965213Ab3DPVHV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 17:07:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

That's a batch of cleanups for the SCTP protocol. Probably all
deadly boring and trivial patches, but it always bugs me. :-) I
guess this is still from the very SCTP beginning in Linux. Well,
at least we can now remove 41 lines of code in total. lksctp-tools
test suite run through without problems.

Daniel Borkmann (9):
  net: sctp: sctp_ssnmap: remove 'malloced' element from struct
  net: sctp: sctp_inq: remove dead code
  net: sctp: sctp_outq: remove 'malloced' from its struct
  net: sctp: sctp_outq: consolidate chars into bitfield
  net: sctp: outqueue: simplify sctp_outq_uncork function
  net: sctp: sctp_transport: remove unused variable
  net: sctp: sctp_bind_addr: remove dead code
  net: sctp: sctp_ulpq: remove 'malloced' struct member
  net: sctp: sctp_ulpq: do not use char as a struct member

 include/net/sctp/structs.h  | 24 ++++--------------------
 include/net/sctp/ulpqueue.h |  3 +--
 net/sctp/bind_addr.c        |  7 -------
 net/sctp/inqueue.c          |  7 -------
 net/sctp/outqueue.c         | 11 ++---------
 net/sctp/ssnmap.c           | 23 ++++++++++++-----------
 net/sctp/transport.c        |  1 -
 net/sctp/ulpqueue.c         |  3 ---
 8 files changed, 19 insertions(+), 60 deletions(-)

-- 
1.7.11.7
