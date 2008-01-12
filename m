From: Bernard Pidoux <pidoux@ccr.jussieu.fr>
Subject: [PATCH 2/4] [ROSE] rose_get_route() template
Date: Sat, 12 Jan 2008 21:17:21 +0100
Message-ID: <47892051.8000404@ccr.jussieu.fr>
References: <47630274.1080706@ccr.jussieu.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Ralf Baechle DL5RB <ralf@linux-mips.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:36026 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757934AbYALURY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 15:17:24 -0500
In-Reply-To: <47630274.1080706@ccr.jussieu.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 From 46bccce1e660a39bcc8f8cf87d4c17de33f4ba48 Mon Sep 17 00:00:00 2001
From: Bernard Pidoux <f6bvp@amsat.org>
Date: Thu, 10 Jan 2008 23:01:46 +0100
Subject: [PATCH 2/4] [ROSE] template declaration for rose_get_route()

Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
  include/net/rose.h |    1 +
  1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/net/rose.h b/include/net/rose.h
index e5bb084..d3ab453 100644
--- a/include/net/rose.h
+++ b/include/net/rose.h
@@ -202,6 +202,7 @@ extern struct net_device *rose_dev_first(void);
  extern struct net_device *rose_dev_get(rose_address *);
  extern struct rose_route *rose_route_free_lci(unsigned int, struct 
rose_neigh *);
  extern struct rose_neigh *rose_get_neigh(rose_address *, unsigned char 
*, unsigned char *);
+extern struct rose_neigh *rose_get_route(rose_address *, unsigned char 
*, unsigned char *);
  extern int  rose_rt_ioctl(unsigned int, void __user *);
  extern void rose_link_failed(ax25_cb *, int);
  extern int  rose_route_frame(struct sk_buff *, ax25_cb *);
--
1.5.3.7


