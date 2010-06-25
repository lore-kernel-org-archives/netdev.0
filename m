From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/1] fix "netpoll: Allow netpoll_setup/cleanup
 recursion"
Date: Thu, 24 Jun 2010 21:27:43 -0700 (PDT)
Message-ID: <20100624.212743.116368090.davem@davemloft.net>
References: <201006250353.o5P3rwti014499@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.hengli.com.au
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58220
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750801Ab0FYE1b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jun 2010 00:27:31 -0400
In-Reply-To: <201006250353.o5P3rwti014499@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Thu, 24 Jun 2010 20:54:01 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Remove rtnl_unlock() which had no corresponding rtnl_lock().
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

I found a time machine and applied this before you even posted
it here :-)
