From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: [PATCH] [bdschuym@pandora.be: Re: ipt_physdev.c alignment problems on parisc64]
Date: Wed, 3 Sep 2003 13:20:23 -0300
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <20030903162022.GI6405@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>,
	Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

Bart,

	Yes, it makes ipt_pysdev.c compile on parisc, Dave, could you please
apply it? Or perhaps wait for the netfilter patches, your call.

- Arnaldo

----- Forwarded message from Bart De Schuymer <bdschuym@pandora.be> -----

Date: Tue, 2 Sep 2003 21:16:41 +0200
From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: ipt_physdev.c alignment problems on parisc64
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	netfilter-devel@lists.netfilter.org
Cc: Linux Networking Development Mailing List <netdev@oss.sgi.com>

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

----- End forwarded message -----
