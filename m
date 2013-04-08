From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK packet
Date: Mon, 08 Apr 2013 14:26:02 -0400
Message-ID: <10426929.HS2uObfqRU@sifl>
References: <20130408154519.18177.57709.stgit@localhost> <1725553.maWFXblPLa@sifl> <1365445303.3887.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, mvadkert@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29713 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934855Ab3DHS0F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 14:26:05 -0400
In-Reply-To: <1365445303.3887.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, April 08, 2013 11:21:43 AM Eric Dumazet wrote:
> On Mon, 2013-04-08 at 14:12 -0400, Paul Moore wrote:
> > It seems a bit fragile to me, perhaps even hacky, but in some ways I guess
> > it isn't anymore fragile than relying on skb->sk - as this problem
> > demonstrates. My other concern is that adding this hook *correctly* is
> > likely to touch a lot of files and may be a bit much so late in the 3.9
> > cycle, Dave, what say you?
>
> I don't get it, 90ba9b1986b5ac4b2d18 was in 3.6, why do you care of
> 3.9 ?

I wasn't made aware of the particular bug until just recently.  When I see a 
regression I generally try to get it fixed as soon as possible.
 
> I am preparing a fix right now. Not a revert, thank you.

I guess we'll have to wait and see then; the more I think about the new hook 
you proposed the less enthused I am about it.

I'm still curious to hear what Dave has to say on this.

-- 
paul moore
security and virtualization @ redhat
