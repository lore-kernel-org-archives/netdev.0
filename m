From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: Re: page allocation failure
Date: Sun, 15 Jun 2008 00:02:16 +0300
Message-ID: <20080614205958.M55299@visp.net.lb>
References: <20080614022451.M72462@visp.net.lb> <20080614065845.GB32585@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:39201 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754601AbYFNVCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Jun 2008 17:02:34 -0400
In-Reply-To: <20080614065845.GB32585@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no jumbo frames in this particular setup.
Probably it is getting out of memory (rtorrent using almost all for fs caching
maybe).

Yes, it seems harmless and seems even useless. I will ignore it from now on :-)
Thanks for info.

On Sat, 14 Jun 2008 10:58:45 +0400, Evgeniy Polyakov wrote
> On Sat, Jun 14, 2008 at 05:25:59AM +0300, Denys Fedoryshchenko 
> (denys@visp.net.lb) wrote:
> > I am not sure it is error, but this message appearing on loaded PC routers.
> > (about 100-150Mbit/s passing there, and rtorrent also running, 1G of ram)
> > 
> > For example:
> > [1407075.519722] swapper: page allocation failure. order:3, mode:0x4020
> > [1407075.519722] Pid: 0, comm: swapper Not tainted 2.6.25.4-devel2 #1
> > [1407075.519722]  [<c0144c09>] __alloc_pages+0x2a9/0x2bd
> > [1407075.519722]  [<c015a606>] __slab_alloc+0x14a/0x45e
> > [1407075.519722]  [<c015b4c9>] __kmalloc_track_caller+0x72/0xb9
> > [1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
> > [1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
> > [1407075.519722]  [<c030156c>] __alloc_skb+0x4d/0xf9
> > [1407075.519722]  [<c03020ae>] __netdev_alloc_skb+0x14/0x2d
> > [1407075.519722]  [<f887f395>] bnx2_poll+0x58f/0xd0c [bnx2]
> 
> It should be harmless. It means that bnx2 does not support jumbo frames
> separated into multiple pages and tries to allocate single huge area.
> 
> -- 
> 	Evgeniy Polyakov


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

