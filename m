From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Thu, 7 Jun 2007 12:09:54 +0400
Message-ID: <20070607080954.GB11764@2ka.mipt.ru>
References: <20070605080542.GA9909@kernel.dk> <20070605143130.GA31747@2ka.mipt.ru> <20070606071725.GE31415@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:47096 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756827AbXFGIKx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jun 2007 04:10:53 -0400
Content-Disposition: inline
In-Reply-To: <20070606071725.GE31415@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 06, 2007 at 09:17:25AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > Some pages have zero reference counter here.
> 
> But it's somewhat annoying to get pages with zero reference counts
> there, I wonder how that happens. I guess if the skb->data originated
> from kmalloc() then we don't really know. The main intent there was just
> to ensure the page wasn't going away, but clearly it's not good enough
> to ensure that reuse isn't taking place.

What bout checking if page belongs to kmalloc cache (or any other cache
via priviate pointers) and do not perform any kind of reference counting
on them? I will play with this a bit later today.

> -- 
> Jens Axboe

-- 
	Evgeniy Polyakov
