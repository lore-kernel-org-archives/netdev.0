From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Remove references to process ID
Date: Fri, 04 May 2007 22:58:29 -0700 (PDT)
Message-ID: <20070504.225829.54189104.davem@davemloft.net>
References: <20070505053343.GA17499@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35653
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1031452AbXEEF62 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 May 2007 01:58:28 -0400
In-Reply-To: <20070505053343.GA17499@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 5 May 2007 15:33:43 +1000

> [NETLINK]: Remove references to process ID
> 
> People treating the *_pid fields in netlink as a process ID has caused
> endless confusion over the years.  The fact that our own netlink.h
> does this only adds to the confusion.
> 
> So here is a patch to change the comments to refer to it as the port
> ID which hopefully will make it clear what the purpose of the fields
> really is.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

I so wish we could just rename that thing to "nl_port".

Thanks for the patch, I'll apply this soon.
