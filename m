From: David Miller <davem@davemloft.net>
Subject: Re: something is wrong in commit 971f10eca1 - tcp: better
 TCP_SKB_CB layout to reduce cache line misses
Date: Fri, 17 Oct 2014 15:29:23 -0400 (EDT)
Message-ID: <20141017.152923.678515861731659347.davem@davemloft.net>
References: <CAHA+R7OEvTcZOm-OepWYvGP+pC_CJRoSen351nw8VJGdLTo0uA@mail.gmail.com>
	<1413409168.17186.0.camel@edumazet-glaptop2.roam.corp.google.com>
	<1413409354.17186.2.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cwang@twopensource.com, kkolasa@winsoft.pl, edumazet@gmail.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753538AbaJQT32 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 15:29:28 -0400
In-Reply-To: <1413409354.17186.2.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Oct 2014 14:42:34 -0700

> On Wed, 2014-10-15 at 14:39 -0700, Eric Dumazet wrote:
>> On Wed, 2014-10-15 at 13:36 -0700, Cong Wang wrote:
>> > On Wed, Oct 15, 2014 at 3:35 AM, Krzysztof Kolasa <kkolasa@winsoft.pl> wrote:
>> > >
>> > > one-line patch not resolve problem, fix created by Cong Wang resolves
>> > > problem !!!
>> > >
>> > > tested on 64bit system and working OK
>> > >
>> > 
>> > So my patch fixes your problem on 64bit but not on 32bit,
>> > is this correct?
>> > 
>> > I will send out the patch. And as Eric said, the problem on 32bit
>> > might be a different issue, we can definitely fix it separately.
>> > 
>> > Thanks for testing!
>> 
>> I think more fixes are needed.
>> 
>> This is most probably an IPv6 issue.
>> 
> 
> Yes, ipv6 uses inet6_iif() a lot. We need to use a different accessor.

So I applied Cong's patches, but if I am to understand the testing feedback
so far only the 64-bit case of the reporter's problems is fixed, and that
the 32-bit graphics corruption still happens.

Can I get some clarification of where we stand after Cong's fixes
which are already merged into 'net'?

Thanks.
