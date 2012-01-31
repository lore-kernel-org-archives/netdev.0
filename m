From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Tue, 31 Jan 2012 09:08:47 +0100
Message-ID: <4F27A18F.3060907@profihost.ag>
References: <20120130171215.GA11508@kroah.com>	<20120130.130717.348683183628737352.davem@davemloft.net>	<4F26E72E.2020007@profihost.ag> <20120130.164828.1695146432151008554.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: greg@kroah.com, eric.dumazet@gmail.com, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.profihost.ag ([85.158.179.208]:54458 "EHLO
	mail.profihost.ag" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751932Ab2AaIIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 03:08:50 -0500
In-Reply-To: <20120130.164828.1695146432151008554.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Hi Greg,

> In all, I think this request is invalid.
>
> You're asking me to submit patches to -stable which don't apply
> even remotely, and whose dependencies haven't even been applied
> to the tree.

i'm sorry but it seems you miss something. The list of matches wasn't
mine it was the list you kernel guys generated in Dec 2011 while you
were discussing my NULL pointer dereference.

I was just a copy and paste by me.

Eric Dumazet (eric.dumazet@xxxxx.com) wrote at 2011-12-01 21:20:
"
Probably fixed by commit f2c31e32b378a665
(net: fix NULL dereferences in check_peer_redir())

But this patch needs some followup patches (some of them in David net
tree, not yet in Linus tree)
"

David Miller wrote:
"
> So can someone please send them to greg => stable@ so we can get them
> into 3.0.X longterm stable.
I'll do it, these things just take care and time.
"

AND some days later:

"
> > any news on that? Systems still crashing every now and then. 3.0.13
> > was released today but i haven't seen any of them.
I only had time to submit these fixes for 3.1.x-stable, you'll just
have to be incredibly patient.
"

As far as i understand the whole problem the (net: fix NULL dereferences
in check_peer_redir()) bug is still in the 3.0 tree but the fix made for
this bug is using a lot of other patches not in 3.0.

So what can we do now?

Stefan
