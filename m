From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] export xfrm_policy_delete
Date: Sun, 21 Nov 2004 19:50:04 -0200
Message-ID: <41A10D8C.2070607@conectiva.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060906030903030105000001"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060906030903030105000001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi David,

         In my DCCP work I'm closely following the TCP code,
so I need this function exported, please consider applying.

Signed-off-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>


--------------060906030903030105000001
Content-Type: text/plain;
 name="xfrm_policy_delete.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="xfrm_policy_delete.patch"

===== net/xfrm/xfrm_policy.c 1.58 vs edited =====
--- 1.58/net/xfrm/xfrm_policy.c	2004-11-09 22:44:26 -02:00
+++ edited/net/xfrm/xfrm_policy.c	2004-11-21 19:43:19 -02:00
@@ -548,6 +548,8 @@
 	}
 }
 
+EXPORT_SYMBOL(xfrm_policy_delete);
+
 int xfrm_sk_policy_insert(struct sock *sk, int dir, struct xfrm_policy *pol)
 {
 	struct xfrm_policy *old_pol;

--------------060906030903030105000001--
