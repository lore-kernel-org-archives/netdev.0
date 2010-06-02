From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] act_nat: fix the wrong checksum when addr isn't in
 old_addr/mask
Date: Wed, 02 Jun 2010 06:52:16 -0700 (PDT)
Message-ID: <20100602.065216.141241865.davem@davemloft.net>
References: <1275179219-10424-1-git-send-email-xiaosuo@gmail.com>
	<1275223421.3587.0.camel@bigi>
	<20100530125811.GA8120@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, xiaosuo@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39870
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755062Ab0FBNwG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jun 2010 09:52:06 -0400
In-Reply-To: <20100530125811.GA8120@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 30 May 2010 22:58:11 +1000

> Yes the patch is correct.
> 
> However, the fact that you need this patch means that your act_nat
> setup isn't perfect.  Ideally all the unNATed packets should be
> filtered out before you hit act_nat.

Regardless of whether said configuration is optimal, we should
handle this case correctly.

So I have applied this patch.
