From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Thu, 14 Jun 2007 13:59:02 +0200
Message-ID: <20070614115902.GG6149@kernel.dk>
References: <20070611115926.GB18832@kernel.dk> <20070612181717.GA1600@2ka.mipt.ru> <20070612181731.GQ18832@kernel.dk> <20070613080103.GA24701@2ka.mipt.ru> <20070614115720.GA14840@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:14972 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751063AbXFNMBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 08:01:40 -0400
Content-Disposition: inline
In-Reply-To: <20070614115720.GA14840@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 14 2007, Evgeniy Polyakov wrote:
> On Wed, Jun 13, 2007 at 12:01:04PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> > I will rebase my tree, likely something was not merged correctly.
> 
> Ok, I've just rebased a tree from recent git and pulled from brick -
> things seems to be settled. I've ran several tests with different
> filesizes and all files were received correctly without kernel crashes.
> There is skb leak indeed, and it looks like it is in the
> __splice_from_pipe() for the last page.

Uh, the leak, right - I had forgotten about that, was working on getting
vmsplice into shape the last two days. Interesting that you mention the
last page, I'll dig in now! Any more info on this (how did you notice
the leak originates from there)?

> Thanks Jens, good work.

Thanks, you're welcome!

-- 
Jens Axboe

