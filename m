From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Tue, 12 Jun 2007 20:18:06 +0200
Message-ID: <20070612181806.GR18832@kernel.dk>
References: <20070611115926.GB18832@kernel.dk> <20070612181717.GA1600@2ka.mipt.ru> <20070612181731.GQ18832@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:9258 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756226AbXFLSU1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 14:20:27 -0400
Content-Disposition: inline
In-Reply-To: <20070612181731.GQ18832@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12 2007, Jens Axboe wrote:
> On Tue, Jun 12 2007, Evgeniy Polyakov wrote:
> > On Mon, Jun 11, 2007 at 01:59:26PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > > Patches are against the #splice branch of the block repo, "official" url
> > > of that is:
> > > 
> > > git://git.kernel.dk/data/git/linux-2.6-block.git/
> > > 
> > > and it's based on Linus main tree. Let me know if I should supply netdev
> > > branch patches instead, or even just provide a rolled up patch (or patch
> > > series) for anyone curious to test or play with it.
> > 
> > Hi Jens.
> > 
> > I've just pulled your tree (splice-net, but splice tree looks the
> > same, git pull says 'Already up-to-date.') on top of linus git and got
> > following bug trace.  I will investigate it further tomorrow.
> 
> Please tell me the contents of splice-net, it looks like you didn't
> actually use the new code. That BUG_ON() is in get_page(), which
> splice-net no longer uses. So the bug report cannot be valid for the
> current code.

Note that I rebase my branches all the time, so you most often want to
use git pull -f to force an update of them.

-- 
Jens Axboe

