From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [BUG] alignment problem in net/core/flow.c:flow_key_compare
Date: Fri, 19 Mar 2004 14:00:28 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319.140028.52992553.yoshfuji@linux-ipv6.org>
References: <20040318162903.59192d13.akpm@osdl.org>
	<20040319.115511.32395995.yoshfuji@linux-ipv6.org>
	<20040318185940.45108d6a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, mru@kth.se, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, davem@redhat.com
In-Reply-To: <20040318185940.45108d6a.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040318185940.45108d6a.akpm@osdl.org> (at Thu, 18 Mar 2004 18:59:40 -0800), Andrew Morton <akpm@osdl.org> says:

> Why not simply
> 
> >  +} __attribute__((__aligned__(BITS_PER_LONG/8)));
> 
> ?

Okay;

===== include/net/flow.h 1.10 vs edited =====
--- 1.10/include/net/flow.h	Thu Jan 15 17:18:43 2004
+++ edited/include/net/flow.h	Fri Mar 19 12:04:32 2004
@@ -77,7 +77,7 @@
 #define fl_icmp_type	uli_u.icmpt.type
 #define fl_icmp_code	uli_u.icmpt.code
 #define fl_ipsec_spi	uli_u.spi
-};
+} __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 #define FLOW_DIR_IN	0
 #define FLOW_DIR_OUT	1

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
