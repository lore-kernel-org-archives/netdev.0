From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO + splice panics in 3.7.0-rc5
Date: Thu, 15 Nov 2012 15:49:04 -0800
Message-ID: <1353023344.10798.8.camel@edumazet-glaptop>
References: <20121115222812.GA647@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f46.google.com ([209.85.210.46]:43059 "EHLO
	mail-da0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751456Ab2KOXtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 18:49:06 -0500
Received: by mail-da0-f46.google.com with SMTP id n41so882812dak.19
        for <netdev@vger.kernel.org>; Thu, 15 Nov 2012 15:49:06 -0800 (PST)
In-Reply-To: <20121115222812.GA647@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 23:28 +0100, Willy Tarreau wrote:
> Hello,
> 
> I was just about to make a quick comparison between LRO and GRO in
> 3.7.0-rc5 to see if LRO still had the big advantage I've always observed,
> but I failed the test because as soon as I enable LRO + splice, the kernel
> panics and reboots.
> 
> I could not yet manage to catch the panic output, I could just reliably
> reproduce it, it crashes instantly.
> 
> All I can say at the moment is the following :
>   - test consist in forwarding HTTP traffic between two NICs via haproxy
>   - driver used was myri10ge
>   - LRO + recv+send : OK
>   - LRO + splice : OK
>   - GRO + recv+send : OK
>   - GRO + splice : panic
>   - no such problem was observed in 3.6.6 so I think this is a recent
>     regression.
> 
> I'll go back digging for more information, but as I'm used to often see
> Eric suggest the right candidates for reverting, I wanted to report the
> issue here in case there are easy ones to try first.

Hi Willy

Nothing particular comes to mind, there were a lot of recent changes
that could trigger this kind of bug.

A stack trace would be useful of course ;)
