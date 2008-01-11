From: Bernard Pidoux F6BVP <f6bvp@free.fr>
Subject: [PATCH] [ROSE] two extra tab characters removed
Date: Fri, 11 Jan 2008 22:40:00 +0100
Message-ID: <4787E230.7090704@free.fr>
References: <20071228214857.GA3290@ami.dom.local>	<20071229.191443.10947724.davem@davemloft.net>	<20071230141323.GA3377@ami.dom.local> <20080110.212242.42433023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g19.free.fr ([212.27.42.35]:47137 "EHLO smtp5-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759787AbYAKVkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 16:40:03 -0500
In-Reply-To: <20080110.212242.42433023.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Bernard Pidoux <f6bvp@amsat.org>
---
  include/net/rose.h |    4 ++--
  1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/rose.h b/include/net/rose.h
index d3ab453..0cfdc0e 100644
--- a/include/net/rose.h
+++ b/include/net/rose.h
@@ -86,7 +86,7 @@ struct rose_neigh {
         ax25_address            callsign;
         ax25_digi               *digipeat;
         ax25_cb                 *ax25;
-       struct net_device               *dev;
+       struct net_device       *dev;
         unsigned short          count;
         unsigned short          use;
         unsigned int            number;
@@ -124,7 +124,7 @@ struct rose_sock {
         ax25_address            source_digis[ROSE_MAX_DIGIS];
         ax25_address            dest_digis[ROSE_MAX_DIGIS];
         struct rose_neigh       *neighbour;
-       struct net_device               *device;
+       struct net_device       *device;
         unsigned int            lci, rand;
         unsigned char           state, condition, qbitincl, defer;
         unsigned char           cause, diagnostic;
--
1.5.3.7
