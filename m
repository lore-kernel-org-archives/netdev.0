From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH repost] netpoll: trapping fix/cleanup
Date: Sat, 28 Apr 2007 08:00:55 -0500
Message-ID: <20070428130055.GW11115@waste.org>
References: <200704272344.00410.sshtylyov@ru.mvista.com> <20070427202713.GS11115@waste.org> <46334477.3070109@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org
To: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:58615 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965805AbXD1NNh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 09:13:37 -0400
Content-Disposition: inline
In-Reply-To: <46334477.3070109@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 28, 2007 at 04:56:23PM +0400, Sergei Shtylyov wrote:
> Hello.
> 
> Matt Mackall wrote:
> 
> >>CONFIG_NETPOLL_TRAP causes the TX queue controls to be completely 
> >>bypassed in
> >>the netpoll's "trapped" mode which easily causes overflows in the drivers 
> >>with
> >>short TX queues (most notably, in 8139too with its 4-deep queue).
> >>Make this option more sensible by only bypassing TX softirq wakeup and 
> >>remove
> >>CONFIG_NETPOLL_RX option completely since there is *no* code depending on 
> >>it.
> 
> >You've got two unrelated patches here, so that's an automatic NAK.
> 
>   Come on, killing a long ago no-op option doesn't worth the sepearte 
>   patch. :-)
> 
> >I suppose we can kill the config option.
> 
>   I've even posted the refs to the commits introducing and killing the 
>   #ifdef's.
> 
> >What did you test the NETPOLL_TRAP test with?
> 
>   KGDBoE (and maybe also netconsole -- don't remember already).

Ok, KGDBoE is a pretty good test here. Netconsole isn't.

Please resend as two separate patches and add:

Acked-by: Matt Mackall <mpm@selenic.com>

-- 
Mathematics is the supreme nostalgia of our time.
