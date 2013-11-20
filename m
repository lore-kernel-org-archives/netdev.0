From: Paul Moore <pmoore@redhat.com>
Subject: Re: [PATCH] cipso: simplify cipso_v4_translate() when !CONFIG_NETLABEL
Date: Wed, 20 Nov 2013 15:09:55 -0500
Message-ID: <1786707.gpV9S7REAB@sifl>
References: <4007061.3MtKnenLV1@sifl> <2049996.Ospk96ghpo@sifl> <20131120.150620.1185820553046155927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754898Ab3KTUJ6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Nov 2013 15:09:58 -0500
In-Reply-To: <20131120.150620.1185820553046155927.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, November 20, 2013 03:06:20 PM David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Wed, 20 Nov 2013 14:59:33 -0500
> 
> > On Wednesday, November 20, 2013 02:55:11 PM David Miller wrote:
> >> 1) This is a cleanup, and therefore not suitable for submission right now
> >>    because the net-next tree is closed.
> > 
> > I wasn't expecting it to go into the current merge window, I was just
> > sending it out now so you'd have it for when things started moving again.
> >  Think of it as spreading the pain out a bit.
> 
> When the merge window opens, I make an announcement here on the list
> politely asking pople to defer net-next patch submissions until after
> the merge window closes and I explicitly announce that net-next is
> open again.

My apologies, I missed that.  Subscribed to too many mailing lists and too 
reliant on my filters to catch the important bits.

> >> 2) A more suitable commit log message would have been "Don't needlessly
> >>    recompute 'opt[opt_iter + 1]' as we already have it stored in
> >>    tag_len".
> >>    
> >>    Then anyone who reads this commit message can say "yes, obviously this
> >>    is a correct change and matches what the patch is doing"
> > 
> > Fair enough.  Do you want a resubmit with your wording once the merge
> > window closes?
> 
> ... and I announce that net-next is open once more, yes.  Thank you.

Will do.

-- 
paul moore
security and virtualization @ redhat
