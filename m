From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] [TIPC]: Fix race condition when creating
 socket or native port
Date: Mon, 12 May 2008 15:42:37 -0700 (PDT)
Message-ID: <20080512.154237.230894375.davem@davemloft.net>
References: <1210624726-3949-1-git-send-email-allan.stephens@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: allan.stephens@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59398
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755374AbYELWmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2008 18:42:42 -0400
In-Reply-To: <1210624726-3949-1-git-send-email-allan.stephens@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>
Date: Mon, 12 May 2008 16:38:46 -0400

> This patch eliminates the (very remote) chance of a crash resulting
> from a partially initialized socket or native port unexpectedly
> receiving a message.  Now, during the creation of a socket or native
> port, the underlying generic port's lock is not released until all
> initialization required to handle incoming messages has been done.
> 
> Signed-off-by: Allan Stephens <allan.stephens@windriver.com>

Also applied, thanks Allan.
