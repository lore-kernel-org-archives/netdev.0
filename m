From: akpm@linux-foundation.org
Subject: [patch 3/3] git-net: sctp build fix (not for applying)
Date: Tue, 02 Oct 2007 14:04:39 -0700
Message-ID: <200710022104.l92L4dvJ022234@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52080 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753673AbXJBVFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 17:05:11 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

net/sctp/sm_statetable.c:551: error: 'sctp_sf_tabort_8_4_8' undeclared here (not in a function)


Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sctp/sm_statetable.c |    2 --
 1 file changed, 2 deletions(-)

diff -puN net/sctp/sm_statetable.c~git-net-sctp-hack net/sctp/sm_statetable.c
--- a/net/sctp/sm_statetable.c~git-net-sctp-hack
+++ a/net/sctp/sm_statetable.c
@@ -527,8 +527,6 @@ static const sctp_sm_table_entry_t prsct
 	/* SCTP_STATE_EMPTY */ \
 	TYPE_SCTP_FUNC(sctp_sf_ootb), \
 	/* SCTP_STATE_CLOSED */ \
-	TYPE_SCTP_FUNC(sctp_sf_tabort_8_4_8), \
-	/* SCTP_STATE_COOKIE_WAIT */ \
 	TYPE_SCTP_FUNC(sctp_sf_discard_chunk), \
 	/* SCTP_STATE_COOKIE_ECHOED */ \
 	TYPE_SCTP_FUNC(sctp_sf_eat_auth), \
_
