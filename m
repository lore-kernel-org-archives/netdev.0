From: Ralf Baechle <ralf@linux-mips.org>
Subject: [PATCH] AX.25: Use constant instead of magic number.
Date: Tue, 18 Oct 2005 21:39:33 +0100
Message-ID: <20051018203932.GA11053@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@conectiva.com.br>,
	dann frazier <dannf@hp.com>, chrisw@osdl.org,
	netdev@vger.kernel.org, linux-hams@vger.kernel.org
Return-path: <linux-hams-owner@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ralf Baechle DL5RB <ralf@linux-mips.org>

 net/rose/rose_route.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

Index: net-git/net/rose/rose_route.c
===================================================================
--- net-git.orig/net/rose/rose_route.c
+++ net-git/net/rose/rose_route.c
@@ -727,7 +727,7 @@ int rose_rt_ioctl(unsigned int cmd, void
 		}
 		if (rose_route.mask > 10) /* Mask can't be more than 10 digits */
 			return -EINVAL;
-		if (rose_route.ndigis > 8) /* No more than 8 digipeats */
+		if (rose_route.ndigis > AX25_MAX_DIGIS)
 			return -EINVAL;
 		err = rose_add_node(&rose_route, dev);
 		dev_put(dev);
