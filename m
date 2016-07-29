From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 0/3] sctp_diag: A bunch of fixes for upcoming 'ss' support
Date: Fri, 29 Jul 2016 18:59:37 +0200
Message-ID: <1469811580-32429-1-git-send-email-phil@nwl.cc>
Cc: Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56942 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbcG2Q77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jul 2016 12:59:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following series contains a number of fixes necessary to make my yet
unpublished 'ss' support patch functional.

Phil Sutter (3):
  sctp: Export struct sctp_info to userspace
  sctp_diag: export timer value only if it is active
  sctp_diag: Respect ss adding TCPF_CLOSE to idiag_states

 include/linux/sctp.h      | 64 -----------------------------------------------
 include/uapi/linux/sctp.h | 64 +++++++++++++++++++++++++++++++++++++++++++++++
 net/sctp/sctp_diag.c      | 14 ++++++-----
 3 files changed, 72 insertions(+), 70 deletions(-)

-- 
2.8.2
