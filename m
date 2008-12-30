From: Hans Lambrechts <hans.lambrechts@skynet.be>
Subject: Re: Happy v2.6.28
Date: Tue, 30 Dec 2008 08:42:34 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0812300835300.3744@server.home.lan>
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
Received: from mailrelay012.isp.belgacom.be ([195.238.6.179]:48555 "EHLO
	mailrelay012.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753994AbYL3Hmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 02:42:37 -0500
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
> 
> Alternatively, you can do a git bisect to pinpoint the broken patch
> between -rc9 and -final.
> 
> 		Pekka
> 


Hi Pekka,

after the first oops I've decided to try 2.6.28 again so I could send 
you more information. I'm running 2.6.28 now for a few days with several 
restarts and no more oops.
This seems a very rare to hit bug or my 6yo box is almost end of life.

	Hans
