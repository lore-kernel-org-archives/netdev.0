From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ftgmac100: Mostly rewrite the driver
Date: Tue, 28 Mar 2017 22:10:27 -0700 (PDT)
Message-ID: <20170328.221027.1436005565229924031.davem@davemloft.net>
References: <1490762446.3177.164.camel@kernel.crashing.org>
        <20170328.215744.794906222630964588.davem@davemloft.net>
        <1490763787.3177.168.camel@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41806 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752571AbdC2FK3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 01:10:29 -0400
In-Reply-To: <1490763787.3177.168.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 29 Mar 2017 16:03:07 +1100

> On Tue, 2017-03-28 at 21:57 -0700, David Miller wrote:
>> This is unreviewable.
>> 
>> You must break this up into small, reviewable pieces.
>> 
>> If you didn't save the steps of your work in that way, that isn't
>> our problem.
> 
> That's not realistic, it would probably not improve the readability
> much. I basically ended up rewriting the driver almost completely
> Dave. It's not even a matter of saving my work steps, each of them
> involved pulling appart an entire side of the old driver and re-doing
> it. 
> 
> That's why I said it's better reviewed as a new driver. We have no
> other user of it in the tree anyway.
> 
> Do you prefer that I submit it as a new driver for that IP block
> instead and take out the old one later ?

You've decided to do this work in a way that makes it nearly
impossible to audit the individual changes for regressions and
whatnot.

That puts a much larger burdon upon us, and introduces much greater
potential risk.

Even a "complete driver rewrite" can and very often is done in a way
which is evolutionary rather than revolutionary.  You made a conscious
decision to just work on this internally and in such a way that one
big huge change is the result.

So, I'm sorry to say, your arguments about readability, realisticness,
etc. I do not buy at all.  You definitely could have done this work in
a way which was more reviewable, and safer, but you choose not to.

Now, what is going to happen, is that we'll have no choice but to
simply accept what you've done and try and review this monster.

Thanks a lot.
