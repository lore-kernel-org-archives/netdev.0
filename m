From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Functions Clean-up
Date: Mon, 24 Feb 2003 16:29:11 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030224.162911.826686204.yoshfuji@linux-ipv6.org>
References: <20030224.125702.13403857.yoshfuji@linux-ipv6.org>
	<20030223.225426.28829614.davem@redhat.com>
	<20030224.161815.511623971.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   netfilter-devel@lists.netfilter.org, kuznet@ms2.inr.ac.ru,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030224.161815.511623971.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030224.161815.511623971.yoshfuji@linux-ipv6.org> (at Mon, 24 Feb 2003 16:18:15 +0900 (JST)), YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org> says:

> In article <20030223.225426.28829614.davem@redhat.com> (at Sun, 23 Feb 2003 22:54:26 -0800 (PST)), "David S. Miller" <davem@redhat.com> says:
> 
> > Hideaki-san, do you try to compile the patches you send
> > to me?  :-)
> 
> sorry, I had compiled with wrong options... :-p
> just a moment, please...

Please apply this patch on top of the previous patch.
Sorry for the mess.

Index: net/ipv6/route.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/route.c,v
retrieving revision 1.1.1.6.12.1
retrieving revision 1.1.1.6.12.2
diff -u -r1.1.1.6.12.1 -r1.1.1.6.12.2
--- net/ipv6/route.c	23 Feb 2003 17:40:42 -0000	1.1.1.6.12.1
+++ net/ipv6/route.c	24 Feb 2003 07:10:02 -0000	1.1.1.6.12.2
@@ -580,7 +580,7 @@
 	int b = plen&0x7;
 	int o = plen>>3;
 
-	memcpy(prefix, addr, o);
+	memcpy(pfx, addr, o);
 	if (o < 16)
 		memset(pfx->s6_addr + o, 0, 16 - o);
 	if (b != 0)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
