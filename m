From: David Miller <davem@davemloft.net>
Subject: Re: tcp: Try to catch MSG_PEEK bug
Date: Tue, 20 Oct 2009 00:52:20 -0700 (PDT)
Message-ID: <20091020.005220.117385594.davem@davemloft.net>
References: <20091020054106.GA5507@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42695
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751112AbZJTHv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Oct 2009 03:51:58 -0400
In-Reply-To: <20091020054106.GA5507@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 20 Oct 2009 14:41:06 +0900

> tcp: Try to catch MSG_PEEK bug
> 
> This patch tries to print out more information when we hit the
> MSG_PEEK bug in tcp_recvmsg.  It's been around since at least
> 2005 and it's about time that we finally fix it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Ok, fair enough, I'll stick this into net-2.6 and hopefully
that will help us.
