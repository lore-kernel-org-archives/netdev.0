From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: Tue, 2 Sep 2003 21:16:41 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309022116.41697.bdschuym@pandora.be>
References: <20030902143050.GC3398@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
   netfilter-devel@lists.netfilter.org
In-Reply-To: <20030902143050.GC3398@conectiva.com.br>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tuesday 02 September 2003 16:30, Arnaldo Carvalho de Melo wrote:
> The 1.786.1.54 changeset (i.e. the initial ipt_physdev.c one 8) created

Does this fix it?

cheers,
Bart

--- linux-2.6.0-test4/include/linux/netfilter_ipv4/ipt_physdev.h.old	2003-09-02 21:11:12.000000000 +0200
+++ linux-2.6.0-test4/include/linux/netfilter_ipv4/ipt_physdev.h	2003-09-02 21:12:30.000000000 +0200
@@ -15,7 +15,7 @@
 struct ipt_physdev_info {
 	u_int8_t invert;
 	u_int8_t bitmask;
-	char physindev[IFNAMSIZ];
+	char physindev[IFNAMSIZ] __attribute__ ((aligned (__alignof__(unsigned long))));
 	char in_mask[IFNAMSIZ];
 	char physoutdev[IFNAMSIZ];
 	char out_mask[IFNAMSIZ];
