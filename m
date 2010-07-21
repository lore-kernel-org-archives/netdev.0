From: David Miller <davem@davemloft.net>
Subject: Re: [patch 3/3] drivers/net/82596.c: fix warning
Date: Wed, 21 Jul 2010 11:18:08 -0700 (PDT)
Message-ID: <20100721.111808.21294525.davem@davemloft.net>
References: <201007202225.o6KMPIQd021449@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, segooon@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757207Ab0GUSRv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jul 2010 14:17:51 -0400
In-Reply-To: <201007202225.o6KMPIQd021449@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Tue, 20 Jul 2010 15:25:18 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/net/82596.c: In function 'i596_open':
> drivers/net/82596.c:1044: warning: label 'err_irq_dev' defined but not used
> 
> Caused by "82596: free resources on error"
> 
> Cc: Kulikov Vasiliy <segooon@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

When this hit the -mm tree, I replied to the -mm postinging that I applied
it to net-next-2.6

So it's integrated already :-)
