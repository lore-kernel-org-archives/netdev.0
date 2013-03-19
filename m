From: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando_b1-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Subject: [PATCH 1/2] man/send(2): add EPERM to the list of possible errors
Date: Tue, 19 Mar 2013 15:45:13 +0900
Message-ID: <1363675513.4767.6.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	Hirotaka Sasaki <sasaki.hirotaka-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
To: Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-man-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Subject: [PATCH 1/2] man/send(2): add EPERM to the list of possible errors

System policy (for example netfilter rule) can cause a send* operation
to fail with EPERM.

Reported-by: Hirotaka Sasaki <sasaki.hirotaka-Zyj7fXuS5i5L9jVzuh4AOg@public.gmane.org>
Signed-off-by: Fernando Luis Vazquez Cao <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>
---

diff -urNp man-pages-3.50-orig/man2/send.2 man-pages-3.50/man2/send.2
--- man-pages-3.50-orig/man2/send.2	2013-03-15 16:17:32.000000000 +0900
+++ man-pages-3.50/man2/send.2	2013-03-19 15:17:03.616008275 +0900
@@ -357,6 +357,10 @@ Some bit in the
 .I flags
 argument is inappropriate for the socket type.
 .TP
+.B EPERM
+System policy (for example a netfilter rule) does not permit the requested
+operation.
+.TP
 .B EPIPE
 The local end has been shut down on a connection oriented socket.
 In this case the process


--
To unsubscribe from this list: send the line "unsubscribe linux-man" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
