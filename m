From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Fri, 15 Jun 2007 15:31:49 +0200
Message-ID: <20070615133149.GX6149@kernel.dk>
References: <20070612181717.GA1600@2ka.mipt.ru> <20070612181731.GQ18832@kernel.dk> <20070613080103.GA24701@2ka.mipt.ru> <20070614115720.GA14840@2ka.mipt.ru> <20070614115902.GG6149@kernel.dk> <20070615080618.GA22234@2ka.mipt.ru> <20070615084318.GP6149@kernel.dk> <20070615091445.GA27451@2ka.mipt.ru> <20070615093429.GQ6149@kernel.dk> <20070615094440.GA26221@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:28021 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753273AbXFONbk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 09:31:40 -0400
Content-Disposition: inline
In-Reply-To: <20070615094440.GA26221@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 15 2007, Evgeniy Polyakov wrote:
> On Fri, Jun 15, 2007 at 11:34:30AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > > Both spd->nr_pages and page_nr are equal to 1. When spd->nr_pages
> > > was 2 there was only 1 free slot in pipe_buffer.
> > 
> > Ah duh, indeed, it is a dumb bug indeed. This should work.
> 
> Yep, this one works too.

Great, thanks for testing!

-- 
Jens Axboe

