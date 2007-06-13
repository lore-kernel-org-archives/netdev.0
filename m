From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive v2
Date: Wed, 13 Jun 2007 12:01:04 +0400
Message-ID: <20070613080103.GA24701@2ka.mipt.ru>
References: <20070611115926.GB18832@kernel.dk> <20070612181717.GA1600@2ka.mipt.ru> <20070612181731.GQ18832@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, olaf.kirch@oracle.com
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44236 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755902AbXFMICk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jun 2007 04:02:40 -0400
Content-Disposition: inline
In-Reply-To: <20070612181731.GQ18832@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 12, 2007 at 08:17:32PM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
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

This is the last commit in that tree:

commit c90a6ce8242d108a5bc6fd0bc1b2aca72a2b5944
Author: Jens Axboe <jens.axboe@oracle.com>
Date:   Mon Jun 11 21:59:50 2007 +0200

TCP splice receive support

Support for network splice receive.

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>

:100644 100644 efc4517... 472ee12... M include/linux/net.h
:100644 100644 e7367c7... 64e3eed... M include/linux/skbuff.h
:100644 100644 a8af9ae... 8e86697... M include/net/tcp.h
:100644 100644 7c6a34e... daea7b0... M net/core/skbuff.c
:100644 100644 041fba3... 0ff9f86... M net/ipv4/af_inet.c
:100644 100644 450f44b... 63efd7a... M net/ipv4/tcp.c
:100644 100644 f453019... 41240f5... M net/socket.c

I will rebase my tree, likely something was not merged correctly.

> -- 
> Jens Axboe

-- 
	Evgeniy Polyakov
