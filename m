From: David Howells <dhowells@redhat.com>
Subject: [PATCH] AF_RXRPC: Add a missing goto
Date: Fri, 07 Dec 2007 11:23:55 +0000
Message-ID: <20071207112355.12996.56012.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33158 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751415AbXLGLX7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2007 06:23:59 -0500
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.1) with ESMTP id lB7BNuoU031780
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 06:23:56 -0500
Received: from pobox.devel.redhat.com (pobox.devel.redhat.com [10.11.255.8])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id lB7BNu3G032344
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2007 06:23:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a missing goto to error handling in the RXKAD security module for AF_RXRPC.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/rxkad.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index e09a95a..8e69d69 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -1021,6 +1021,7 @@ static int rxkad_verify_response(struct rxrpc_connection *conn,
 
 	abort_code = RXKADINCONSISTENCY;
 	if (version != RXKAD_VERSION)
+		goto protocol_error;
 
 	abort_code = RXKADTICKETLEN;
 	if (ticket_len < 4 || ticket_len > MAXKRB5TICKETLEN)

