From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Sevaral MLD Fixes
Date: Fri, 18 Oct 2002 18:52:58 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021018.185258.27026815.davem@redhat.com>
References: <20021018.125223.130322644.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20021018.125223.130322644.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I had to add the following to my tree after this patch,
please watch for compiler warnings introducted by your
changes.   Thanks :-)

--- net/ipv6/mcast.c.~1~	Fri Oct 18 18:55:04 2002
+++ net/ipv6/mcast.c	Fri Oct 18 18:55:16 2002
@@ -605,8 +605,6 @@
 
 static void igmp6_leave_group(struct ifmcaddr6 *ma)
 {
-	int addr_type;
-
 	if (IPV6_ADDR_MC_SCOPE(&ma->mca_addr) < IPV6_ADDR_SCOPE_LINKLOCAL ||
 	    ipv6_addr_is_ll_all_nodes(&ma->mca_addr))
 		return;
