From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next v2 0/6] SCTP updates
Date: Sat, 12 Jul 2014 20:30:34 +0200
Message-ID: <1405189840-31171-1-git-send-email-dborkman@redhat.com>
Cc: geirola@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2625 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752635AbaGLSao (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2014 14:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This set improves the SCTP socket API to be more in line with
RFC6458, Geir and myself have finalized it eventually. While
at it, the first patch also fixes two possible information
leaks that should go to net tree as well. For more details, I
refer you to the patches themselves.

Thanks a lot.

v1 -> v2:
 - Added 6th patch to deprecate SCTP_SNDRCV, rest unchanged

Daniel Borkmann (2):
  net: sctp: fix information leaks in ulpevent layer
  net: sctp: deprecate rfc6458, 5.3.2. SCTP_SNDRCV support

Geir Ola Vaagland (4):
  net: sctp: implement rfc6458, 5.3.4. SCTP_SNDINFO cmsg support
  net: sctp: implement rfc6458, 5.3.5. SCTP_RCVINFO cmsg support
  net: sctp: implement rfc6458, 5.3.6. SCTP_NXTINFO cmsg support
  net: sctp: implement rfc6458, 8.1.31. SCTP_DEFAULT_SNDINFO support

 include/net/sctp/sctp.h     |   1 +
 include/net/sctp/structs.h  |   7 +-
 include/net/sctp/ulpevent.h |  14 +--
 include/uapi/linux/sctp.h   | 102 +++++++++++----
 net/sctp/socket.c           | 294 ++++++++++++++++++++++++++++++++++++++------
 net/sctp/ulpevent.c         | 185 ++++++++++++----------------
 6 files changed, 430 insertions(+), 173 deletions(-)

-- 
1.7.11.7
