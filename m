From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use WARN() for the WARN_ON in commit b6b39e8f3fbbb
Date: Thu, 22 Oct 2009 21:38:12 -0700 (PDT)
Message-ID: <20091022.213812.83606333.davem@davemloft.net>
References: <20091022203512.1d714d5a@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751228AbZJWEht (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 00:37:49 -0400
In-Reply-To: <20091022203512.1d714d5a@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Thu, 22 Oct 2009 20:35:12 -0700

> Commit b6b39e8f3fbbb (tcp: Try to catch MSG_PEEK bug) added a printk()
> to the WARN_ON() that's in tcp.c. This patch changes this combination
> to WARN(); the advantage of WARN() is that the printk message shows up
> inside the message, so that kerneloops.org will collect the message.
> 
> In addition, this gets rid of an extra if() statement.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>

Applied, thanks.
