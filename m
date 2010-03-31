From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 09:06:13 -0400
Message-ID: <1270040773.26743.12.camel@bigi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
	 <20100331110345.GC12845@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.25]:62052 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933252Ab0CaNGR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 09:06:17 -0400
Received: by qw-out-2122.google.com with SMTP id 8so20762qwh.37
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 06:06:16 -0700 (PDT)
In-Reply-To: <20100331110345.GC12845@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 19:03 +0800, Herbert Xu wrote:

> This seems to be bogus to me.  Just because the DB was empty
> before the flush doesn't mean that the flush didn't happen.

Herbert, If a tree falls in a forest and no one is around to hear it,
does it make a sound? ;->
A flush event is meant to be a signal to user space that what
was once a non-empty table is now empty. 
This is a consistent definition of the semantics everywhere tables
are flushed (not just in Linux)..

What makes the SPD and SAD speacial?

cheers,
jamal



