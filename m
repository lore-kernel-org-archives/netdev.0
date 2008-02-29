From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 03/08 net-2.6.26] [TIPC]: Eliminate "sparse" warning in
 socket code
Date: Fri, 29 Feb 2008 11:48:26 -0800 (PST)
Message-ID: <20080229.114826.61001754.davem@davemloft.net>
References: <AF1602CB2550CE4381C0C75118A7856B0252DE22@ala-mail02.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39428
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754889AbYB2Ts0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 14:48:26 -0500
In-Reply-To: <AF1602CB2550CE4381C0C75118A7856B0252DE22@ala-mail02.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Stephens, Allan" <allan.stephens@windriver.com>
Date: Fri, 29 Feb 2008 10:40:46 -0800

> @@ -81,6 +81,12 @@ static int sockets_enabled = 0;
>  
>  static atomic_t tipc_queue_size = ATOMIC_INIT(0);
>  
> +/*
> + * Declare public routines so "sparse" doesn't complain ...
> + */
> +
> +extern int  tipc_socket_init(void);
> +extern void tipc_socket_stop(void);
>  

This should belong in a header file, and you should make sure
the header gets included in all the necessary C files that
either define or invoke these functions.
