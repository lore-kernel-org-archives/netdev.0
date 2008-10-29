From: Paul Moore <paul.moore@hp.com>
Subject: Re: linux-next: arm allmodconfig
Date: Wed, 29 Oct 2008 16:12:45 -0400
Message-ID: <200810291612.46074.paul.moore@hp.com>
References: <20081028175604.81c31cea.akpm@linux-foundation.org> <200810290953.03105.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	Dave Airlie <airlied@linux.ie>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Takashi Iwai <tiwai@suse.de>,
	Pekka Enberg <penberg@cs.helsinki.fi>, xfs-masters@oss.sgi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:16486 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426AbYJ2UNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 16:13:53 -0400
In-Reply-To: <200810290953.03105.paul.moore@hp.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 29 October 2008 9:53:02 am Paul Moore wrote:
> On Tuesday 28 October 2008 8:56:04 pm Andrew Morton wrote:
> > > net/netlabel/netlabel_mgmt.c: In function
> > > `netlbl_mgmt_listentry': net/netlabel/netlabel_mgmt.c:268:
> > > warning: 'ret_val' might be used uninitialized in this function
> >
> > Assumes that netlbl_af4list_foreach_rcu() will never iterate zero
> > times.
> >
> > Assumes that entry->type can never have an unexpected value.
> >
> > gcc cannot get this right, and C-level changes will be needed to
> > shut this up.
>
> No idea why this didn't come up when I was compiling this ... oh
> well, good thing I'm not a proud guy :)  I'll get this fixed and post
> a patch later today.

I updated my lblnet-2.6_next tree with a fix as well as another patch 
from Roel Kluin to fix a signed/unsigned mistake.  I'll post the 
patches to the relevant lists but I'm waiting one more patch from 
someone first.

In the meantime, interested parties can find the git tree here:

 * git://git.infradead.org/users/pcmoore/lblnet-2.6_next

-- 
paul moore
linux @ hp
