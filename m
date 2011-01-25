From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Revert 'administrative down' address handling
 changes.
Date: Tue, 25 Jan 2011 12:49:08 -0800 (PST)
Message-ID: <20110125.124908.112599966.davem@davemloft.net>
References: <20110124.233813.246546891.davem@davemloft.net>
	<m1zkqp2woo.fsf@fess.ebiederm.org>
	<m1ei803ja4.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, brian.haley@hp.com,
	lorenzo@google.com, herbert@gondor.hengli.com.au
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33970
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753149Ab1AYUse (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 15:48:34 -0500
In-Reply-To: <m1ei803ja4.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 25 Jan 2011 10:55:31 -0800

> ebiederm@xmission.com (Eric W. Biederman) writes:
> 
>> David Miller <davem@davemloft.net> writes:
>>
>>> From: David Miller <davem@davemloft.net>
>>> Date: Sun, 23 Jan 2011 23:41:01 -0800 (PST)
>>>
>>>> Eric B. and co., please do some testing to make sure all of your
>>>> disable_ipv6 cases are functioning properly with this applied.
>>>
>>> Ping?
>>
>> In progress.  I had to make a small change to your patch to get it
>> to apply against 2.6.37.  neigh_ifdown has not been removed from the
>> beginning of addrconf_ifdown there.  The piece that was failing for
>> me is not failing now so, so far so good.
>>
>> It was reported that in 2.6.37 there was a new regression that
>> 1connecting to ::1 when ipv6 was disabled would not fail immediately but
>> would have to wait a while.  With your patch applied I am not seeing
>> that behavior either.
>>
>> Tomorrow I should know if I see any weird side effects with your patch,
>> after my regression tests for everything else have finished running.
> 
> I have to admit I am seeing weird side effects.  A test that was
> mysteriously failing because it could not create a vlan on top of a tap
> device has started working again ;)
> 
> So this change is looking really good for me.

Thanks for the testing feedback, that's looking good enough for me,
I'll start pushing this fix around.
