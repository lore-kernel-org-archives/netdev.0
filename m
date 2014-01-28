From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] af_packet: Add PACKET_FANOUT_QM documentation
Date: Tue, 28 Jan 2014 07:16:15 -0500
Message-ID: <1390911375-5784-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>, mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Recently added a new fanout mode of operation to packet sockets.  Document it
here

Signed-off-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
CC: mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
CC: andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org
CC: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 man7/packet.7 | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/man7/packet.7 b/man7/packet.7
index 93f91e9..6e145dc 100644
--- a/man7/packet.7
+++ b/man7/packet.7
@@ -296,6 +296,8 @@ processes all data on a single socket, moves to the next when one
 becomes backlogged.
 .BR PACKET_FANOUT_RND
 selects the socket using a pseudo-random number generator.
+.BR PACKET_FANOUT_QM
+selects the socket using the recorded queue_mapping of the received skb.
 
 Fanout modes can take additional options.
 IP fragmentation causes packets from the same flow to have different
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
