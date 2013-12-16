From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 0/2] two bpf tools fixes
Date: Mon, 16 Dec 2013 11:44:59 +0100
Message-ID: <1387190701-1893-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50657 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124Ab3LPKpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 05:45:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found two follow-up things that need to be fixed. Thanks!

Daniel Borkmann (2):
  bpf_dbg: always close socket in bpf_runnable
  bpf_exp: free duplicated labels at exit time

 tools/net/bpf_dbg.c |  2 +-
 tools/net/bpf_exp.y | 27 ++++++++++++++++++++-------
 2 files changed, 21 insertions(+), 8 deletions(-)

-- 
1.8.3.1
