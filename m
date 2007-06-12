From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive
Date: Tue, 12 Jun 2007 15:11:32 +0200
Message-ID: <20070612131131.GH18832@kernel.dk>
References: <20070608135819.GA14302@2ka.mipt.ru> <20070608141452.GR7341@kernel.dk> <20070608145724.GA14561@2ka.mipt.ru> <20070608153011.GA2375@2ka.mipt.ru> <20070609063608.GX7341@kernel.dk> <20070612112950.GA16477@2ka.mipt.ru> <20070612113352.GA18832@kernel.dk> <20070612123540.GB16477@2ka.mipt.ru> <20070612124005.GC18832@kernel.dk> <20070612131153.GC16477@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:12534 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755411AbXFLNNu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 09:13:50 -0400
Content-Disposition: inline
In-Reply-To: <20070612131153.GC16477@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12 2007, Evgeniy Polyakov wrote:
> > difference between changing parts of the elements of a structure to just
> > grabbing a reference to it. If the skb cannot be referenced, skb_get()
> > should return NULL.
> > 
> > But that aside, I see the issue. I'll just stick to the clone, it works
> > fine as-is (well almost, there's a leak there, but functionally it's
> > ok!).
> 
> Btw, is it allowed to use splice from network with, say, nfs?
> Since RPC code uses sk_user_data as long as network splice.

It doesn't anymore, see the version posted today (or yesterday, but it
would be silly to read older code than the newest :-)

-- 
Jens Axboe

