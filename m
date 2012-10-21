From: Willy Tarreau <w@1wt.eu>
Subject: Re: 3.5 bridging regression
Date: Sun, 21 Oct 2012 17:37:16 +0200
Message-ID: <20121021153716.GH21937@1wt.eu>
References: <20121021112727.GF21937@1wt.eu> <1350820413.13333.2042.camel@edumazet-glaptop> <20121021132610.GG21937@1wt.eu> <1350827202.13333.2284.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:33881 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932226Ab2JUPha (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Oct 2012 11:37:30 -0400
Content-Disposition: inline
In-Reply-To: <1350827202.13333.2284.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 21, 2012 at 03:46:42PM +0200, Eric Dumazet wrote:
> Thanks for testing, sorry for adding a bug.

No problem, thanks to you for the quick fix.

> skb_recycle() was losing skb->head_frag status.
> 
> (we could have added some logic in skb_is_recycleable(), but this
> function was becoming really too complex)

OK. I remember you did this in order to permit zero-copy splice() with
all network drivers. I'll recheck to see if there is a performance impact
with the fix.

Cheers,
Willy
