From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 12:49:45 -0400 (EDT)
Message-ID: <20170516.124945.386235742645153398.davem@davemloft.net>
References: <1494950224.3259.98.camel@redhat.com>
        <20170516.122923.869994491617365845.davem@davemloft.net>
        <1494952963.3259.109.camel@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Bart.VanAssche@sandisk.com, torvalds@linux-foundation.org,
        hch@lst.de, netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50926 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbdEPQts (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 12:49:48 -0400
In-Reply-To: <1494952963.3259.109.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Doug Ledford <dledford@redhat.com>
Date: Tue, 16 May 2017 12:42:43 -0400

> On Tue, 2017-05-16 at 12:29 -0400, David Miller wrote:
>> From: Doug Ledford <dledford@redhat.com>
>> Date: Tue, 16 May 2017 11:57:04 -0400
>> 
>> > Regardless though, I'm rather purturbed about this entire thing.
>>  If
>> > you are right that because this got into 4.11, it's now a done
>> deal,
>> > then the fact that this went through 4 review cycles on netdev@
>> that,
>> > as I understand it, spanned roughly one years time, and not one
>> single
>> > person bothered to note that this was as much an RDMA driver as
>> > anything else, and not one person bothered to note that linux-rdma@ 
>> was
>> > not on the Cc: list, and not one person told the submitters that
>> they
>> > needed to include linux-rdma@ on the Cc: list of these submissions,
>> and
>> > you took it without any review comments from any RDMA people in the
>> > course of a year, or an ack from me to show that the RDMA portion
>> of
>> > this had at least been given some sort of review, was a collosal
>> fuckup
>> > of cross tree maintainer cooperation.
>> 
>> We rely on people from various areas of expertiece to contribute to
>> patch review on netdev and give appropriate feedback.
>> 
>> If you actually look through the history, I made many semantic
>> reviews
>> of the SMC changes, and kept pushing back.
>> 
>> And in fact I did this several times, making them go through several
>> revisions, in the hopes that someone would review more of the meat
>> and
>> substance of the patch set.
> 
> If you want to walk to the mailbox, you walk to the mailbox, you don't
> walk to the grocery store, to the gym, and never even go to the
> mailbox.  Likewise, if you want review from RDMA experts, most (maybe
> even all) don't subscribe to netdev@ because it's too high traffic, you
> don't waste time on silly semantic pushbacks, you send a single email
> that says "Please get review from linux-rdma@, thank you."  Don't beat
> around the bush, be direct and get it over with.  That's exactly what I
> do for all netdev@ related patches coming to linux-rdma@ without a
> proper Cc: to netdev@.

Read my other email, it wasn't %100 clear to me that this was so
strictly RDMA related.  And I kept pushing back with semantic changes
in part because it wasn't clear.

So as far as I was concerned I was not necessarily going to the wrong
store, in fact I wasn't sure what store to go to.

And none of the thousands of subscribers to netdev intuit'd this
either.  Maybe there is a reason for that.

Furthermore, if netdev is too much traffic for one or two RDMA people
to just casually subscribe to on the off chance that a situationm like
this comes up, guess what it is like for me who has to read and review
pretty much every single posting that is placed there?
