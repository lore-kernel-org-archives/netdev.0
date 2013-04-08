From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 13:55:01 -0700
Message-ID: <1365454501.3887.45.camel@edumazet-glaptop>
References: <20130408154519.18177.57709.stgit@localhost>
	 <1365445303.3887.33.camel@edumazet-glaptop>
	 <1365445825.3887.35.camel@edumazet-glaptop> <3294227.D2rod7xgQB@sifl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mvadkert@redhat.com
To: Paul Moore <pmoore@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:37138 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752181Ab3DHUzE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 16:55:04 -0400
Received: by mail-pa0-f53.google.com with SMTP id bh4so3424803pad.26
        for <netdev@vger.kernel.org>; Mon, 08 Apr 2013 13:55:03 -0700 (PDT)
In-Reply-To: <3294227.D2rod7xgQB@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-08 at 16:37 -0400, Paul Moore wrote:

> The people who use this functionality almost never use upstream kernels, they 
> need to protection/certification/warm-fuzzies/etc. that come from a 
> distribution kernel and a support infrastructure.  I didn't catch it because I 
> use a slightly different configuration that didn't expose this bug; while I 
> would like to run a full regression test every release I simply don't have the 
> time to do that myself.
> 
> > This sounds like a very small issue to me, a revert is simply overkill.
> 
> It all depends on your use case.  To you, whom I assume doesn't use SELinux, 
> it is indeed a trivial issue.  To someone who relies on SELinux for its 
> network access controls this is a pretty significant issue.
> 

Is the patch I sent addressing the problem or not ?

Note that I do have : CONFIG_SECURITY=y

So this patch basically adds the overhead back, and I'll have to use
real hook later in net-next.

At least my patch clearly _shows_ the security requirement, instead of
relying on a side effect of a previous sock_wmalloc()

Again, it would be nice you understand the plan.
