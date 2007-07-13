From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH][RFC] network splice receive v3
Date: Fri, 13 Jul 2007 14:21:00 +0200
Message-ID: <20070713122058.GL5328@kernel.dk>
References: <20070711091927.GQ4587@kernel.dk> <20070712170247.GA18469@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	olaf.kirch@oracle.com
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([80.160.20.94]:25284 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755996AbXGMMVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jul 2007 08:21:15 -0400
Content-Disposition: inline
In-Reply-To: <20070712170247.GA18469@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 12 2007, Evgeniy Polyakov wrote:
> On Wed, Jul 11, 2007 at 11:19:27AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> > Hi,
> 
> Hi Jens.
> 
> > Here's an updated implementation of tcp network splice receive support.
> > It actually works for me now, no data corruption seen.
> > 
> > For the original announcement and how to test it, see:
> > 
> > http://marc.info/?l=linux-netdev&m=118103093400770&w=2
> > 
> > The splice core changes needed to support this are now merged in
> > 2.6.22-git, so the patchset shrinks to just two patches - one for adding
> > a release hook, and one for the networking changes.
> > 
> > The code is also available in the splice-net branch here:
> > 
> > git://git.kernel.dk/data/git/linux-2.6-block.git splice-net
> > 
> > There's a third experimental patch in there that allows vmsplice
> > directly to user memory, that still needs some work though.
> > 
> > Comments, testing welcome!
> 
> It looks like you included all bits we found in the previous runs, so
> likely it will work good, but so far I have conflicts merging todays git
> and your tree in include/linux/splice.h, fs/ext2/file.c, fs/splice.c and 
> mm/filemap_xip.c. This can be a problem with my tree though.

Hmm, the patch should apply directly to the tree as of when I posted
this original mail, or any later one. I just tried a rebase, and it
rebased fine on top of the current -git as well. So I think the issue is
with your tree, sorry!

> It really looks like the last tree we tested, so if you think additional
> one will not hurt, feel free to ping, so I will completely rebase
> testing tree.

It would be great if you could retest! There are some minor changes in
there, and some extra testing definitely will not hurt.

-- 
Jens Axboe

