From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH net-next] net: drivers: kill two unused macro definitions
Date: Sat, 14 May 2011 09:53:35 +0200
Message-ID: <20110514075334.GA2751@psychotron>
References: <4DCE2A7F.1040000@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, andy@greyhouse.net,
	David Miller <davem@davemloft.net>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	ebiederm@aristanetworks.com, netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22069 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752190Ab1ENHyA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 May 2011 03:54:00 -0400
Content-Disposition: inline
In-Reply-To: <4DCE2A7F.1040000@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sat, May 14, 2011 at 09:08:47AM CEST, shanwei@cn.fujitsu.com wrote:
>
>
>Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>---
> drivers/net/bonding/bonding.h |   10 ----------
> drivers/net/veth.c            |    1 -
> 2 files changed, 0 insertions(+), 11 deletions(-)
>
>diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>index d08362e..ea1d005 100644
>--- a/drivers/net/bonding/bonding.h
>+++ b/drivers/net/bonding/bonding.h
>@@ -39,16 +39,6 @@
> 	       netif_carrier_ok(dev))
> 
> /*
>- * Checks whether bond is ready for transmit.
>- *
>- * Caller must hold bond->lock
>- */
>-#define BOND_IS_OK(bond)			     \
>-		   (((bond)->dev->flags & IFF_UP) && \
>-		    netif_running((bond)->dev)	  && \
>-		    ((bond)->slave_cnt > 0))
>-
>-/*
>  * Checks whether slave is ready for transmit.
>  */
> #define SLAVE_IS_OK(slave)			        \
>diff --git a/drivers/net/veth.c b/drivers/net/veth.c
>index 3b0151a..8461576 100644
>--- a/drivers/net/veth.c
>+++ b/drivers/net/veth.c
>@@ -22,7 +22,6 @@
> 
> #define MIN_MTU 68		/* Min L3 MTU */
> #define MAX_MTU 65535		/* Max L3 MTU (arbitrary) */
>-#define MTU_PAD (ETH_HLEN + 4)  /* Max difference between L2 and L3 size MTU */
> 
> struct veth_net_stats {
> 	unsigned long	rx_packets;
>-- 
>1.7.4.1


Reviewed-by: Jiri Pirko <jpirko@redhat.com>

