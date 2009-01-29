From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
 hashing.
Date: Wed, 28 Jan 2009 21:01:42 -0800 (PST)
Message-ID: <20090128.210142.06933232.davem@davemloft.net>
References: <20090129013403.GA24043@gondor.apana.org.au>
	<20090128.174522.208349319.davem@davemloft.net>
	<20090129044148.GA25131@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750749AbZA2FBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 00:01:44 -0500
In-Reply-To: <20090129044148.GA25131@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 29 Jan 2009 15:41:48 +1100

> But yeah if a single TX queue isn't big enough to take care of
> the output from a single core then you will need multiple TX
> queues.  Although from an system-wide point of view it would
> seem to be more optimal to make that TX queue bigger rather than
> forcing the software to use multiple queues (which may come with
> a bigger overhead) to make up for it.
> 
> Of course for us software developers we don't really have a choice :)

Yes, this is one of the things I told Robert, make the
TX queues larger :-)

Besides, a plain iterating RX --> TX function can't work because
that doesn't take flows into consideration and thus can introduce
reordering.
