From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: MLDv1 /proc/net/igmp6 timer printing [PATCH]
Date: Wed, 19 Nov 2003 17:05:00 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031119.170500.33118773.yoshfuji@linux-ipv6.org>
References: <OFC259A8D3.0F02136D-ON88256DE3.002BA960@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OFC259A8D3.0F02136D-ON88256DE3.002BA960@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFC259A8D3.0F02136D-ON88256DE3.002BA960@us.ibm.com> (at Wed, 19 Nov 2003 00:59:20 -0700), David Stevens <dlstevens@us.ibm.com> says:

> Ok, here's the revised patch.

please fix ipv4 as well.

Index: net/ipv4/igmp.c
===================================================================
RCS file: /cvsroot/usagi/usagi/kernel/linux26/net/ipv4/igmp.c,v
retrieving revision 1.20
retrieving revision 1.21
diff -u -r1.20 -r1.21
--- net/ipv4/igmp.c	9 Oct 2003 02:49:24 -0000	1.20
+++ net/ipv4/igmp.c	19 Nov 2003 07:11:46 -0000	1.21
@@ -2215,7 +2215,7 @@
 		seq_printf(seq,
 			   "\t\t\t\t%08lX %5d %d:%08lX\t\t%d\n",
 			   im->multiaddr, im->users,
-			   im->tm_running, im->timer.expires-jiffies, im->reporter);
+			   im->tm_running, jiffies_to_clock_t(im->timer.expires-jiffies), im->reporter);
 	}
 	return 0;
 }

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
