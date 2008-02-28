From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [GIT PATCHES 0/4] SCTP updates
Date: Thu, 28 Feb 2008 16:52:37 -0500
Message-ID: <1204235561-19993-1-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, lksctp-developers@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:13739 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbYB1VwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 16:52:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David

The following is a set of fixes for SCTP.  I think most of them constitute
bug fixes, but I'll let you review them and have the final word.

You can also pull them from 
  vxy@master.kernel.org:/pub/scm/linux/kernel/git/vxy/lksctp-dev.git pending

Short log:

Neil Horman (1):
      [SCTP]: Clean up naming conventions of sctp protocol/address family
registration

Vlad Yasevich (3):
      [SCTP]: Correctly set the length of sctp_assoc_change notification
      [SCTP]: Incorrect length was used in SCTP_*_AUTH_CHUNKS socket option
      [SCTP]: Update AUTH structures to match declarations in draft-16.

 include/net/sctp/user.h |   10 ++++++----
 net/sctp/auth.c         |    4 ++--
 net/sctp/ipv6.c         |   12 ++++++------
 net/sctp/protocol.c     |   12 ++++++------
 net/sctp/socket.c       |   18 +++++++++++++-----
 net/sctp/ulpevent.c     |    2 +-
 6 files changed, 34 insertions(+), 24 deletions(-)

Thanks
-vlad
