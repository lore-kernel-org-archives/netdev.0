From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive v3
Date: Thu, 12 Jul 2007 21:02:47 +0400
Message-ID: <20070712170247.GA18469@2ka.mipt.ru>
References: <20070711091927.GQ4587@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	olaf.kirch@oracle.com
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:51338 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752996AbXGLRDS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Jul 2007 13:03:18 -0400
Content-Disposition: inline
In-Reply-To: <20070711091927.GQ4587@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 11, 2007 at 11:19:27AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> Hi,

Hi Jens.

> Here's an updated implementation of tcp network splice receive support.
> It actually works for me now, no data corruption seen.
> 
> For the original announcement and how to test it, see:
> 
> http://marc.info/?l=linux-netdev&m=118103093400770&w=2
> 
> The splice core changes needed to support this are now merged in
> 2.6.22-git, so the patchset shrinks to just two patches - one for adding
> a release hook, and one for the networking changes.
> 
> The code is also available in the splice-net branch here:
> 
> git://git.kernel.dk/data/git/linux-2.6-block.git splice-net
> 
> There's a third experimental patch in there that allows vmsplice
> directly to user memory, that still needs some work though.
> 
> Comments, testing welcome!

It looks like you included all bits we found in the previous runs, so
likely it will work good, but so far I have conflicts merging todays git
and your tree in include/linux/splice.h, fs/ext2/file.c, fs/splice.c and 
mm/filemap_xip.c. This can be a problem with my tree though.
It really looks like the last tree we tested, so if you think additional
one will not hurt, feel free to ping, so I will completely rebase
testing tree.

> -- 
> Jens Axboe


-- 
	Evgeniy Polyakov
