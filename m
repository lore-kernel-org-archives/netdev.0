From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] Misc SCTP updates
Date: Mon, 30 Jun 2014 13:52:07 +0200
Message-ID: <1404129129-23270-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752592AbaF3LwM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 07:52:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (2):
  net: sctp: improve timer slack calculation for transport HBs
  net: sctp: only warn in proc_sctp_do_alpha_beta if write

 include/net/sctp/sctp.h | 21 ---------------------
 net/sctp/sysctl.c       |  5 +++--
 net/sctp/transport.c    | 17 +++++++++--------
 3 files changed, 12 insertions(+), 31 deletions(-)

-- 
1.7.11.7
