From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 14 Jul 2008 23:26:20 +0200
Message-ID: <20080714212620.GA8503@orion.carnet.hr>
References: <20080710223141.GA2519@orion.carnet.hr> <20080710.162007.04790623.davem@davemloft.net> <20080711092416.GA26515@orion.carnet.hr> <20080711.025656.261409874.davem@davemloft.net> <48787E1A.3030804@gmail.com> <4878AFD8.1000307@gmail.com> <487B7061.5040306@trash.net> <20080714172055.GA2638@ami.dom.local> <20080714202151.GA28622@orion.carnet.hr> <20080714212223.GA4849@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:52063 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758249AbYGNV01 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 17:26:27 -0400
Content-Disposition: inline
In-Reply-To: <20080714212223.GA4849@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 11:22:23PM +0200, Jarek Poplawski wrote:
> On Mon, Jul 14, 2008 at 10:21:51PM +0200, Josip Rodin wrote:
> > On Mon, Jul 14, 2008 at 07:20:55PM +0200, Jarek Poplawski wrote:
> ...
> > > BTW, I wonder how Josip's testing?
> > 
> > Do you want me to try out David's patch? I was hoping to get a definite okay
> > from someone before applying it, given that this is a production machine
> > for us and we do need it in *some* kind of an operational state.
> 
> Hmm... if you trust me more than David?! As a matter of fact, I thought
> it's under testing already, but since I've some doubts, I attach below
> my version of David's patch. IMHO, it looks safe, but never knows...

No (sorry :) but he did call his patch an "idiotic attempt", and asked you
guys for input, so I held back :)

> > I've got many more tens of kilobytes of logs from the previous debugging
> > patches, if you want I can send them over.
> 
> This debugging, I guess, shows corrupted data, but the reason is hard
> to find. David found one of possible reasons and it needs checking. I
> don't think this patch in any version can do more damage than doing
> nothing - unless you prefer to use Michael's patch to next kernels
> (BTW, don't remove this patch yet).

OK, I'll give it a whirl.

(Should I update to .26 at the same time, now that it went live in the
meantime?)

-- 
     2. That which causes joy or happiness.
