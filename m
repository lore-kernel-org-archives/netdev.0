From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: INGO Why you remove  set_user_nice() from kernel/kthread.c
Date: Mon, 14 Sep 2009 10:31:19 -0600
Message-ID: <4AAE6FD7.5070401@nortel.com>
References: <200909141742.45487.pavel@pavlinux.ru>	 <1252937140.6500.11.camel@marge.simson.net>  <4AAE5D60.2080703@nortel.com> <1252943123.12986.70.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pavel@pavlinux.ru, linux-kernel@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Mike Galbraith <efault@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zcars04e.nortel.com ([47.129.242.56]:63597 "EHLO
	zcars04e.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207AbZINQc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 12:32:29 -0400
In-Reply-To: <1252943123.12986.70.camel@marge.simson.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/14/2009 09:45 AM, Mike Galbraith wrote:
> On Mon, 2009-09-14 at 09:12 -0600, Chris Friesen wrote:
>> On 09/14/2009 08:05 AM, Mike Galbraith wrote:

>>> I did that, not Ingo, and did so because with kthreads that use
>>> diddly-spit CPU (every one I see), it's just a waste of math.  What
>>> kthreads are you seeing using so much CPU that their weight is a factor?
>>> They _should_ be able to preempt and get their work done just fine
>>> without a boost.
>>
>> Under heavy network load ksoftirqd can use significant amounts of cpu.
> 
> OK, that may justify a weight adjustment, since it is a proxy for many.
> Question is, does it really need it?

I guess it depends how we want it to behave by default.  Likely anyone
that really cares is going to fine-tune the ksoftirqd priority level
anyways.

I've added netdev to the CC list.  Maybe some of the people there have
an opinion on what the default priority should be for ksoftirqd.

Chris
