From: Josip Rodin <joy@entuzijast.net>
Subject: Re: bnx2_poll panicking kernel
Date: Mon, 14 Jul 2008 22:21:51 +0200
Message-ID: <20080714202151.GA28622@orion.carnet.hr>
References: <20080710223141.GA2519@orion.carnet.hr> <20080710.162007.04790623.davem@davemloft.net> <20080711092416.GA26515@orion.carnet.hr> <20080711.025656.261409874.davem@davemloft.net> <48787E1A.3030804@gmail.com> <4878AFD8.1000307@gmail.com> <487B7061.5040306@trash.net> <20080714172055.GA2638@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, mchan@broadcom.com,
	billfink@mindspring.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, mirrors@debian.org, devik@cdi.cz
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orion.CARNet.hr ([161.53.160.90]:34234 "EHLO orion.carnet.hr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbYGNUV7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jul 2008 16:21:59 -0400
Content-Disposition: inline
In-Reply-To: <20080714172055.GA2638@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 14, 2008 at 07:20:55PM +0200, Jarek Poplawski wrote:
> On Mon, Jul 14, 2008 at 05:27:29PM +0200, Patrick McHardy wrote:
> > Jarek Poplawski wrote:
> >> Jarek Poplawski wrote, On 07/12/2008 11:49 AM:
> >>
> >>> This isn't correct: htb_activate() needs cl->un.leaf.q->q.qlen > 0, and
> >>> only NET_XMIT_SUCCESS can guarantee this.
> >>
> >>
> >> ...Actually, it looks like even NET_XMIT_SUCCESS can't guarantee this
> >> (when returned after TC_ACT_QUEUED or TC_ACT_STOLEN), so additional qlen
> >> test is needed here.
> >
> > The TC action code translation needs to be fixed instead.
> >
> > I didn't manage to work on this this weekend as I intended, but
> > I'll take care of it soon unless someone beats me to it.
> 
> IMHO, since this TC_ACT_ issue looks quite rare, David's patch, with
> "htb_activate()" moved to the last "if (ret == NET_XMIT_SUCCESS)"
> blocks, looks like necessary.
> 
> BTW, I wonder how Josip's testing?

Do you want me to try out David's patch? I was hoping to get a definite okay
from someone before applying it, given that this is a production machine
for us and we do need it in *some* kind of an operational state.

I've got many more tens of kilobytes of logs from the previous debugging
patches, if you want I can send them over.

-- 
     2. That which causes joy or happiness.
