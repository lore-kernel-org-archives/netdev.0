From: Pekka Enberg <penberg@cs.helsinki.fi>
Subject: Re: Happy v2.6.28
Date: Mon, 29 Dec 2008 12:57:10 +0200
Message-ID: <1230548230.8603.5.camel@penberg-laptop>
References: <bMLNZ-3QM-1@gated-at.bofh.it>
	 <200812250853.mBP8rxrr004080@server.home.lan>
	 <84144f020812250426x255cc00esd33f0075292b486b@mail.gmail.com>
	 <Pine.LNX.4.64.0812251336320.4497@server.home.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Hans Lambrechts <hans.lambrechts@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:57424 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbYL2K5M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2008 05:57:12 -0500
In-Reply-To: <Pine.LNX.4.64.0812251336320.4497@server.home.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hans,

On Thu, 2008-12-25 at 13:45 +0100, Hans Lambrechts wrote:
> > Looks like slab corruption. Can we have your .config, please? I'm
> > cc'ing netdev as the oops happens in kmem_cache_alloc() so the
> > networking code is a prime suspect of the corrupting kmem_cache_free()
> > call (although the bug might be elsewhere as well).

Can you boot the kernel with "slub_debug slub_nomerge" passed as kernel
parameters and try to reproduce the oops, please? Maybe we can get more
information on the bug.

Alternatively, you can do a git bisect to pinpoint the broken patch
between -rc9 and -final.

		Pekka

