From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pktgen: allow faster module unload
Date: Sun, 21 Nov 2010 09:56:36 -0800 (PST)
Message-ID: <20101121.095636.71126038.davem@davemloft.net>
References: <1290359251.2756.134.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39010
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754720Ab0KUR4L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Nov 2010 12:56:11 -0500
In-Reply-To: <1290359251.2756.134.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 21 Nov 2010 18:07:31 +0100

> @@ -395,6 +395,8 @@ struct pktgen_hdr {
>  	__be32 tv_usec;
>  };
>  
> +bool pktgen_exiting __read_mostly;
> +
>  struct pktgen_thread {
>  	spinlock_t if_lock;		/* for list of devices */
>  	struct list_head if_list;	/* All device here */

Maybe this should be static?
