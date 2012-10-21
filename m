From: Willy Tarreau <w@1wt.eu>
Subject: Re: 3.5 bridging regression
Date: Sun, 21 Oct 2012 15:26:10 +0200
Message-ID: <20121021132610.GG21937@1wt.eu>
References: <20121021112727.GF21937@1wt.eu> <1350820413.13333.2042.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:33865 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753572Ab2JUN0P (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2012 09:26:15 -0400
Content-Disposition: inline
In-Reply-To: <1350820413.13333.2042.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 21, 2012 at 01:53:33PM +0200, Eric Dumazet wrote:
> Hello Willy
> 
> This is most probably the needed fix.

Good catch, as usual ! It works flawlessly here on top of 3.6.2.

> I guess David planned to send it to stable teams if not already done.

Indeed, I've not seen it there yet.

David, are you OK with sending this patch for -stable ? It fixes
a 3.5 regression causing bridge to panic.

> commit acb600def2110b1310466c0e485c0d26299898ae
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Fri Oct 5 06:23:55 2012 +0000
> 
>     net: remove skb recycling
>     
>     Over time, skb recycling infrastructure got litle interest and
>     many bugs. Generic rx path skb allocation is now using page
>     fragments for efficient GRO / TCP coalescing, and recyling
>     a tx skb for rx path is not worth the pain.

Thanks and have a nice week-end !
Willy
