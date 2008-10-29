From: Dave Chinner <david@fromorbit.com>
Subject: Re: [xfs-masters] Re: linux-next: arm allmodconfig
Date: Thu, 30 Oct 2008 09:07:32 +1100
Message-ID: <20081029220732.GK4985@disturbed>
References: <20081028175604.81c31cea.akpm@linux-foundation.org> <20081029074032.GI4985@disturbed> <20081029082459.GA6364@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Paul Moore <paul.moore@hp.com>, Takashi Iwai <tiwai@suse.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>
To: xfs-masters@oss.sgi.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ipmail04.adl2.internode.on.net ([203.16.214.57]:28126 "EHLO
	ipmail04.adl2.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752335AbYJ2WHs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 18:07:48 -0400
Content-Disposition: inline
In-Reply-To: <20081029082459.GA6364@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 29, 2008 at 09:24:59AM +0100, Ingo Molnar wrote:
> 
> * Dave Chinner <david@fromorbit.com> wrote:
> 
> > > > fs/xfs/xfs_rtalloc.c: In function `xfs_growfs_rt':
> > > > fs/xfs/xfs_rtalloc.c:1875: warning: 'tp' might be used uninitialized in this function
> > 
> > False positive, and I don't get this reported, either.
> > 
> > Hold on - the above gcc binary only emits a warning for the 
> > xfs_growfs_rt issue when CONFIG_CC_OPTIMIZE_FOR_SIZE=y is set. It 
> > still doesn't catch the quota bug, though. This is so fucked up....
> 
> FYI, i've got 3 XFS warnings mapped in tip/auto-warnings-next:
> 
>  earth4:~/tip> gll linus..auto-warnings-next | grep xfs
> 
>  ec2f37c: work around warning in fs/xfs/xfs_mount.c

Can't say I've ever seen that warning. What gcc version is
generating it?

>  8501db3: work around warning in fs/xfs/xfs_rtalloc.c

Yeah, that's bogus.

>  8077af8: warnings: fix xfs posix acl

Should be fixed in the -next tree.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
