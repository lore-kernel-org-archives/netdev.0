From: Bruce Allan <bwa@us.ibm.com>
Subject: Re: [PATCH] subset of RFC2553
Date: 24 Feb 2003 09:54:57 -0800
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1046109300.3503.12.camel@w-bwa1.beaverton.ibm.com>
References: <3E54128C.327D7759@us.ibm.com>
	<20030219.162129.11584427.davem@redhat.com>
	<1045847170.3104.7.camel@w-bwa1.beaverton.ibm.com>
	<20030221.232639.129509431.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030221.232639.129509431.davem@redhat.com>
List-Id: netdev.vger.kernel.org

Doh!  Sorry, here (see below) it is against 2.5.59.

On Fri, 2003-02-21 at 23:26, David S. Miller wrote:
> 
> Bruce, while applying this I noticed that in6addr_{any,loopback}
> are not exported by modules.
> 
> Please send me a small patch to add the exports if this will be
> needed by SCTP and friends.
> 
> Thanks.
> 

--- linux-2.5.59/net/ipv6/ipv6_syms.c	2003-01-16 18:22:25.000000000 -0800
+++ linux-2.5.59-RFC2553/net/ipv6/ipv6_syms.c	2003-02-24 09:02:41.000000000 -0800
@@ -25,3 +25,5 @@
 EXPORT_SYMBOL(inet6_ioctl);
 EXPORT_SYMBOL(ipv6_get_saddr);
 EXPORT_SYMBOL(ipv6_chk_addr);
+EXPORT_SYMBOL(in6addr_any);
+EXPORT_SYMBOL(in6addr_loopback);

-- 
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR

