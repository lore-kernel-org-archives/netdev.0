From: David Miller <davem@davemloft.net>
Subject: Re: net nasties in davem's tree
Date: Thu, 29 Mar 2007 19:03:17 -0700 (PDT)
Message-ID: <20070329.190317.26277628.davem@davemloft.net>
References: <20070329183730.566f41c6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753803AbXC3CDT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 22:03:19 -0400
In-Reply-To: <20070329183730.566f41c6.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Thu, 29 Mar 2007 18:37:30 -0700

> drivers/net/3c523.c: In function 'elmc_send_packet':
> drivers/net/3c523.c:1148: warning: passing argument 2 of 'skb_copy_from_linear_data' discards qualifiers from pointer target type
> drivers/net/ni52.c: In function 'ni52_send_packet':
> drivers/net/ni52.c:1185: warning: passing argument 2 of 'skb_copy_from_linear_data' discards qualifiers from pointer target type

We should probably mark the "to" argument to skb_copy_from_linear_data()
as const, I'll take care of that.

Thanks for the report.
