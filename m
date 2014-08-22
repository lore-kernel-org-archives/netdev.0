From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 0/2] SCTP fix
Date: Fri, 22 Aug 2014 13:03:28 +0200
Message-ID: <1408705410-28558-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752166AbaHVLDf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2014 07:03:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daniel Borkmann (2):
  net: sctp: spare unnecessary comparison in sctp_trans_elect_best
  net: sctp: fix suboptimal edge-case on non-active active/retrans path selection

 net/sctp/associola.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

-- 
1.7.11.7
