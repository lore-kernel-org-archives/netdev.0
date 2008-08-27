From: Andi Kleen <andi@firstfloor.org>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Thu, 28 Aug 2008 00:57:25 +0200
Message-ID: <87fxoqqd62.fsf@basil.nowhere.org>
References: <87zlmyr5nz.fsf@basil.nowhere.org>
	<20080827.142941.50104491.davem@davemloft.net>
	<20080827223410.GC26610@one.firstfloor.org>
	<20080827.153907.157997966.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davej@redhat.com, netdev@vger.kernel.org, j.w.r.degoede@hhs.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:52187 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752874AbYH0W5b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 18:57:31 -0400
In-Reply-To: <20080827.153907.157997966.davem@davemloft.net> (David Miller's message of "Wed, 27 Aug 2008 15:39:07 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: Andi Kleen <andi@firstfloor.org>
> Date: Thu, 28 Aug 2008 00:34:10 +0200
>
>> It fixes an old performance problem at least. I'm not aware 
>> of any new ones in this area because the code in this 
>> function hasn't changed since I last looked.
>
> That's exactly what this thread is about, things got slower for
> some reason even though nothing specifically changed in this area.

I reread the original bug and it says nothing about a regression
(unless I'm blind). I think the reporter just ran into the slowness that
was pretty much always there[1] (and which my patch improves)

-Andi

[1] ok it got more noticeable over time because people 
have more memory than they used to have, which made
the hash table bigger.

-- 
ak@linux.intel.com
