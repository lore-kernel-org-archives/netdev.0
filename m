From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v3 net] net: solve a NAPI race
Date: Mon, 27 Feb 2017 15:23:15 -0800
Message-ID: <20170227152315.7e3b284f@xeon-e3>
References: <20170227141403.714490f7@xeon-e3>
        <1488234917.9415.217.camel@edumazet-glaptop3.roam.corp.google.com>
        <20170227144455.174ab1e5@xeon-e3>
        <20170227.174854.1727197935165904806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36742 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751392AbdB1BSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 20:18:06 -0500
Received: by mail-pg0-f50.google.com with SMTP id s67so50990999pgb.3
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 17:17:52 -0800 (PST)
In-Reply-To: <20170227.174854.1727197935165904806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Feb 2017 17:48:54 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <stephen@networkplumber.org>
> Date: Mon, 27 Feb 2017 14:44:55 -0800
> 
> > On Mon, 27 Feb 2017 14:35:17 -0800
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >   
> >> On Mon, 2017-02-27 at 14:14 -0800, Stephen Hemminger wrote:
> >>   
> >> > The original design (as Davem mentioned) was that IRQ's must be disabled
> >> > during device polling. If that was true, then the race above
> >> > would be impossible.    
> >> 
> >> I would love to see an alternative patch.  
> > 
> > Turn off busy poll? 
> > The poll stuff runs risk of breaking more things.  
> 
> Eric is exactly trying to make busy poll even more prominent in
> the stack, not less prominent.
> 
> It's an important component of some performance improvements he is
> working on.

Maybe making IRQ controlled as part of the network device model
(instead of a side effect left to device driver to handle) would
be less problematic.

Really just shooting in the dark because I don't have any of the problematic
hardware to play with.
