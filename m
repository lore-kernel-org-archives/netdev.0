From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] net: ip, ipv6: handle gso skbs in forwarding path
Date: Tue, 28 Jan 2014 09:30:33 -0800
Message-ID: <1390930233.28432.16.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1390810971-23959-1-git-send-email-fw@strlen.de>
	 <1390810971-23959-2-git-send-email-fw@strlen.de>
	 <1390846967.27806.75.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140128085706.GB30123@breakpoint.cc>
	 <1390926883.28432.12.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140128171519.GC30123@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f49.google.com ([209.85.214.49]:44995 "EHLO
	mail-bk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755182AbaA1Raj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jan 2014 12:30:39 -0500
Received: by mail-bk0-f49.google.com with SMTP id v15so517669bkz.36
        for <netdev@vger.kernel.org>; Tue, 28 Jan 2014 09:30:38 -0800 (PST)
In-Reply-To: <20140128171519.GC30123@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-01-28 at 18:15 +0100, Florian Westphal wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > Eric, any chance you know wheter mucking with gso_size in this way
> > > is supposed to work?
> > > 
> > > I will go through skb_segment and see if I can find out what exactly causes this
> > > BUG_ON to trigger.
> > 
> > This is definitely net-next material anyway, no hurry ;)
> 
> Yes, looks like it :)
> 
> Eric, do you mind if I re-send the patch with skb_gso_segment and a zero
> feature mask?



I think the xmit will take care of doing the fallback anyway, if skb
need to be linear or TX checksum be computed. 

> I think thats the best solution for -net.  I would then try to come up
> with a version that follows your "shrink gso_size" suggestion for -next.

Note that I mentioned this MTU thing months ago, and the bug is here
since years. I do not think its a very urgent matter :)
