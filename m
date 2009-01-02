From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: Happy v2.6.28
Date: Fri, 2 Jan 2009 08:06:29 -0600 (CST)
Message-ID: <Pine.LNX.4.64.0901020806090.31302@quilx.com>
References: <bMLNZ-3QM-1@gated-at.bofh.it>  <200812250853.mBP8rxrr004080@server.home.lan>
  <84144f020812250426x255cc00esd33f0075292b486b@mail.gmail.com>
 <Pine.LNX.4.64.0812251336320.4497@server.home.lan> <1230548230.8603.5.camel@penberg-laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Hans Lambrechts <hans.lambrechts@skynet.be>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nlpi025.sbcis.sbc.com ([207.115.36.54]:40921 "EHLO
	nlpi025.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754669AbZABOG5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 09:06:57 -0500
In-Reply-To: <1230548230.8603.5.camel@penberg-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Dec 2008, Pekka Enberg wrote:

> Hi Hans,
>
> On Thu, 2008-12-25 at 13:45 +0100, Hans Lambrechts wrote:
> > > Looks like slab corruption. Can we have your .config, please? I'm
> > > cc'ing netdev as the oops happens in kmem_cache_alloc() so the
> > > networking code is a prime suspect of the corrupting kmem_cache_free()
> > > call (although the bug might be elsewhere as well).
>
> Can you boot the kernel with "slub_debug slub_nomerge" passed as kernel
> parameters and try to reproduce the oops, please? Maybe we can get more
> information on the bug.

slub_debug implies slub_nomerge

