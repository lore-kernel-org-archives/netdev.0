From: James Morris <jmorris@intercode.com.au>
Subject: [PATCH][IPV6] compile fix for net/ipv6/route.c in current bk
Date: Sun, 18 May 2003 12:29:53 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0305181227260.21143-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: =?iso-2022-jp?Q?YOSHIFUJI_Hideaki_=2F_=1B$B5HF#1QL=40=1B=28B?= <yoshfuji@linux-ipv6.org>,
   <kuznet@ms2.inr.ac.ru>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This version of the ip6_null_entry initializer is needed for complation to 
succeed with gcc version 2.96 20000731 (Red Hat Linux 7.3 2.96-110).


- James
-- 
James Morris
<jmorris@intercode.com.au>

--- bk.pending/net/ipv6/route.c	Sun May 18 11:51:40 2003
+++ bk.w1/net/ipv6/route.c	Sun May 18 13:26:28 2003
@@ -108,7 +108,7 @@
 			.dev		= &loopback_dev,
 			.obsolete	= -1,
 			.error		= -ENETUNREACH,
-			.metrics[RTAX_HOPLIMIT-1] = 255,
+			.metrics	= {[RTAX_HOPLIMIT-1] = 255},
 			.input		= ip6_pkt_discard,
 			.output		= ip6_pkt_discard,
 			.ops		= &ip6_dst_ops,
