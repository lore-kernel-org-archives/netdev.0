From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Major network performance regression in 3.7
Date: Sat, 05 Jan 2013 18:22:13 -0800
Message-ID: <1357438933.1678.5223.camel@edumazet-glaptop>
References: <20130105214958.GA19814@1wt.eu>
	 <1357427926.1678.4771.camel@edumazet-glaptop>
	 <20130105232913.GQ16031@1wt.eu>
	 <1357430523.1678.4901.camel@edumazet-glaptop>
	 <20130106005053.GS16031@1wt.eu>
	 <1357435276.1678.5067.camel@edumazet-glaptop>
	 <20130106013027.GV16031@1wt.eu>
	 <1357436430.1678.5111.camel@edumazet-glaptop>
	 <1357437086.1678.5135.camel@edumazet-glaptop>
	 <1357438591.1678.5205.camel@edumazet-glaptop>
	 <20130106021824.GW16031@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:44639 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754959Ab3AFCWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 21:22:17 -0500
In-Reply-To: <20130106021824.GW16031@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-06 at 03:18 +0100, Willy Tarreau wrote:
> On Sat, Jan 05, 2013 at 06:16:31PM -0800, Eric Dumazet wrote:
> > On Sat, 2013-01-05 at 17:51 -0800, Eric Dumazet wrote:
> > > On Sat, 2013-01-05 at 17:40 -0800, Eric Dumazet wrote:
> > > > On Sun, 2013-01-06 at 02:30 +0100, Willy Tarreau wrote:
> > > > 
> > > > > Ah interesting because these were some of the mm patches that I had
> > > > > tried to revert.
> > > > 
> > > > Hmm, or we should fix __skb_splice_bits()
> > > > 
> > > > I'll send a patch.
> > > > 
> > > 
> > > Could you try the following ?
> > 
> > Or more exactly...
> 
> The first one did not change a iota unfortunately. I'm about to
> spot the commit causing the loopback regression. It's a few patches
> before the first one you pointed. It's almost finished and I test
> your patch below immediately after.

I bet you are going to find commit
69b08f62e17439ee3d436faf0b9a7ca6fffb78db
(net: use bigger pages in __netdev_alloc_frag )

Am I wrong ?
