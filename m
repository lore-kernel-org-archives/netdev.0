From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Thu, 14 Jun 2007 15:57:20 +0400
Message-ID: <20070614115720.GA14840@2ka.mipt.ru>
References: <20070611115926.GB18832@kernel.dk> <20070612181717.GA1600@2ka.mipt.ru> <20070612181731.GQ18832@kernel.dk> <20070613080103.GA24701@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:49966 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751023AbXFNL5h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jun 2007 07:57:37 -0400
Content-Disposition: inline
In-Reply-To: <20070613080103.GA24701@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 13, 2007 at 12:01:04PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> I will rebase my tree, likely something was not merged correctly.

Ok, I've just rebased a tree from recent git and pulled from brick -
things seems to be settled. I've ran several tests with different
filesizes and all files were received correctly without kernel crashes.
There is skb leak indeed, and it looks like it is in the
__splice_from_pipe() for the last page.

Thanks Jens, good work.

-- 
	Evgeniy Polyakov
