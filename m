From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH][SCTP] Use ipv6_addr_any rather than ipv6_addr_type in
 sctp_v6_is_any().
Date: Fri, 22 Apr 2005 12:28:56 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504221214560.5192@dyn9047018105.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, lksctp-developers@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi Dave,

Please apply to 2.6.

Thanks
Sridhar

=============================================================================
[SCTP] Use ipv6_addr_any() rather than ipv6_addr_type() in sctp_v6_is_any().

Signed-off-by: Brian Haley <Brian.Haley@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
=============================================================================
diff -Nru a/net/sctp/ipv6.c b/net/sctp/ipv6.c
--- a/net/sctp/ipv6.c	2005-04-21 16:21:58 -07:00
+++ b/net/sctp/ipv6.c	2005-04-21 16:21:58 -07:00
@@ -496,9 +496,7 @@
  /* Is this a wildcard address? */
  static int sctp_v6_is_any(const union sctp_addr *addr)
  {
-	int type;
-	type = ipv6_addr_type((struct in6_addr *)&addr->v6.sin6_addr);
-	return IPV6_ADDR_ANY == type;
+	return ipv6_addr_any(&addr->v6.sin6_addr);
  }

  /* Should this be available for binding?   */
