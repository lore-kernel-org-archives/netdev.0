From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/3] Minor sctp cleanups
Date: Fri,  7 Jun 2013 10:35:03 +0200
Message-ID: <1370594106-25745-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41902 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391Ab3FGIfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 04:35:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (3):
  net: sctp: let sctp_destroy_sock destroy related members
  net: sctp: sctp_association_init: hold refs in reverse order
  net: sctp: minor: remove variable in sctp_init_sock

 net/sctp/associola.c   |  5 ++---
 net/sctp/endpointola.c |  7 -------
 net/sctp/socket.c      | 15 +++++++++++----
 3 files changed, 13 insertions(+), 14 deletions(-)

-- 
1.7.11.7
