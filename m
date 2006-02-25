From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] net/dccp/ipv4.c: make struct dccp_v4_prot static
Date: Sat, 25 Feb 2006 14:27:29 +0100
Message-ID: <20060225132729.GP3674@stusta.de>
References: <20060224031002.0f7ff92a.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030245AbWBYN1d@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, davem@davemloft.net,
	acme@conectiva.com.br
Content-Disposition: inline
In-Reply-To: <20060224031002.0f7ff92a.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 24, 2006 at 03:10:02AM -0800, Andrew Morton wrote:
>...
> Changes since 2.6.16-rc4-mm1:
>...
>  git-net.patch
>...
>  git trees.
>...


There's no reason for struct dccp_v4_prot being global.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc4-mm2-full/net/dccp/ipv4.c.old	2006-02-25 04:32:45.000000000 +0100
+++ linux-2.6.16-rc4-mm2-full/net/dccp/ipv4.c	2006-02-25 04:32:53.000000000 +0100
@@ -1022,7 +1022,7 @@
 	.twsk_obj_size	= sizeof(struct inet_timewait_sock),
 };
 
-struct proto dccp_v4_prot = {
+static struct proto dccp_v4_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
 	.close			= dccp_close,
