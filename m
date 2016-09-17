From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 01/14] rxrpc: Remove some whitespace.
Date: Sun, 18 Sep 2016 00:17:51 +0100
Message-ID: <147415427192.17897.16407917712450524592.stgit@warthog.procyon.org.uk>
References: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41344 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932827AbcIQXRy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Sep 2016 19:17:54 -0400
In-Reply-To: <147415426459.17897.13899206413543061473.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove a tab that's on a line that should otherwise be blank.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/call_event.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/rxrpc/call_event.c b/net/rxrpc/call_event.c
index 61432049869b..9367c3be31eb 100644
--- a/net/rxrpc/call_event.c
+++ b/net/rxrpc/call_event.c
@@ -31,7 +31,7 @@ static void rxrpc_set_timer(struct rxrpc_call *call)
 	_enter("{%ld,%ld,%ld:%ld}",
 	       call->ack_at - now, call->resend_at - now, call->expire_at - now,
 	       call->timer.expires - now);
-	
+
 	read_lock_bh(&call->state_lock);
 
 	if (call->state < RXRPC_CALL_COMPLETE) {
