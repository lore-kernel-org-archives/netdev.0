From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH -next 0/2] net: allow setting ecn via routing table
Date: Thu, 30 Oct 2014 14:07:40 -0700
Message-ID: <1414703260.15352.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1414276729-17871-1-git-send-email-fw@strlen.de>
	 <20141028.165737.2009356944765978630.davem@davemloft.net>
	 <20141029122307.GA29253@breakpoint.cc>
	 <20141030.155958.156984068627586090.davem@davemloft.net>
	 <20141030205204.GE10069@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:54997 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161019AbaJ3VHm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 17:07:42 -0400
Received: by mail-ie0-f175.google.com with SMTP id y20so13715ier.20
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 14:07:41 -0700 (PDT)
In-Reply-To: <20141030205204.GE10069@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-30 at 21:52 +0100, Florian Westphal wrote:

> So, what about changing the default to 1 in net-next?
> 
> We could add automatic 'no-ecn' to retransmitted syns to avoid
> ecn blackholes (Daniel Borkmann has a patch for this), and, in case
> ecn=1 causes too much breakage we can always revert (and re-consider ecn
> per route settings as an intermediate step).
> 
> What do you think?

I think this is way too dangerous.

I played a lot with ECN in the past (and fixed number of bugs in linux)
and discovered many times I had to disable it to be able to surf the
Internet.

I am kind of an expert so always could figure out what was the problem,
but average user wont have the choice.

Reverting might take a long long time, it wont help people stuck behind
buggy equipment.
