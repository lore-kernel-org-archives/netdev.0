From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/7] rxrpc: Actually display the tx_data trace
 retransmission note
Date: Fri, 30 Sep 2016 22:40:18 +0100
Message-ID: <147527161870.28826.15533380797413095818.stgit@warthog.procyon.org.uk>
References: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147527161156.28826.2148784664652062075.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Actually display in the tx_data trace the retransmission note added in a
previous patch.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/trace/events/rxrpc.h |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/rxrpc.h b/include/trace/events/rxrpc.h
index 8ba8d76e856a..67f03946ea4a 100644
--- a/include/trace/events/rxrpc.h
+++ b/include/trace/events/rxrpc.h
@@ -280,11 +280,12 @@ TRACE_EVENT(rxrpc_tx_data,
 		    __entry->lose = lose;
 			   ),
 
-	    TP_printk("c=%p DATA %08x q=%08x fl=%02x%s",
+	    TP_printk("c=%p DATA %08x q=%08x fl=%02x%s%s",
 		      __entry->call,
 		      __entry->serial,
 		      __entry->seq,
 		      __entry->flags,
+		      __entry->retrans ? " *RETRANS*" : "",
 		      __entry->lose ? " *LOSE*" : "")
 	    );
 
