From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 5/8] rxrpc: Do a little bit of tidying in the ICMP
 processing
Date: Wed, 15 Jun 2016 17:42:13 +0100
Message-ID: <146600893348.18270.9226995532265575434.stgit@warthog.procyon.org.uk>
References: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-afs@lists.infradead.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54173 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932862AbcFOQmP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 12:42:15 -0400
In-Reply-To: <146600889842.18270.2306896489831492957.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do a little bit of tidying in the ICMP processing code.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/peer_event.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/rxrpc/peer_event.c b/net/rxrpc/peer_event.c
index 6ba798d6659e..31c440acd8c9 100644
--- a/net/rxrpc/peer_event.c
+++ b/net/rxrpc/peer_event.c
@@ -245,15 +245,13 @@ void rxrpc_UDP_error_handler(struct work_struct *work)
 		break;
 
 	case SO_EE_ORIGIN_LOCAL:
-		_proto("Rx Received local error { error=%d }",
-		       ee->ee_errno);
+		_proto("Rx Received local error { error=%d }", err);
 		break;
 
 	case SO_EE_ORIGIN_NONE:
 	case SO_EE_ORIGIN_ICMP6:
 	default:
-		_proto("Rx Received error report { orig=%u }",
-		       ee->ee_origin);
+		_proto("Rx Received error report { orig=%u }", ee->ee_origin);
 		break;
 	}
 
