From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@wide.ad.jp>
Subject: Re: [Bugme-new] [Bug 4274] New: ipv6: Unknown symbol
 tcp_timer_bug_msg
Date: Thu, 03 Mar 2005 02:37:06 +0900 (JST)
Message-ID: <20050303.023706.64945563.yoshfuji@wide.ad.jp>
References: <20050302091907.19bb2b2e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: akpm@osdl.org, jgoerzen@complete.org
In-Reply-To: <20050302091907.19bb2b2e.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20050302091907.19bb2b2e.akpm@osdl.org> (at Wed, 2 Mar 2005 09:19:07 -0800), Andrew Morton <akpm@osdl.org> says:

> modprobe ipv6 fails with:
> 
> ipv6: Unknown symbol tcp_timer_bug_msg

Please try this.

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

===== net/ipv4/tcp_timer.c 1.30 vs edited =====
--- 1.30/net/ipv4/tcp_timer.c	2005-02-23 03:45:32 +09:00
+++ edited/net/ipv4/tcp_timer.c	2005-03-03 02:26:20 +09:00
@@ -38,6 +38,7 @@
 
 #ifdef TCP_DEBUG
 const char tcp_timer_bug_msg[] = KERN_DEBUG "tcpbug: unknown timer value\n";
+EXPORT_SYMBOL(tcp_timer_bug_msg);
 #endif
 
 /*

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
