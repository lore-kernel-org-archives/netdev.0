From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] ipv6: Revert 'administrative down' address handling changes.
Date: Tue, 25 Jan 2011 10:55:31 -0800
Message-ID: <m1ei803ja4.fsf@fess.ebiederm.org>
References: <20110123.234101.71098533.davem@davemloft.net>
	<20110124.233813.246546891.davem@davemloft.net>
	<m1zkqp2woo.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, brian.haley@hp.com,
	lorenzo@google.com, herbert@gondor.hengli.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:54020 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab1AYSzm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jan 2011 13:55:42 -0500
In-Reply-To: <m1zkqp2woo.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Tue, 25 Jan 2011 00:51:19 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> David Miller <davem@davemloft.net> writes:
>
>> From: David Miller <davem@davemloft.net>
>> Date: Sun, 23 Jan 2011 23:41:01 -0800 (PST)
>>
>>> Eric B. and co., please do some testing to make sure all of your
>>> disable_ipv6 cases are functioning properly with this applied.
>>
>> Ping?
>
> In progress.  I had to make a small change to your patch to get it
> to apply against 2.6.37.  neigh_ifdown has not been removed from the
> beginning of addrconf_ifdown there.  The piece that was failing for
> me is not failing now so, so far so good.
>
> It was reported that in 2.6.37 there was a new regression that
> 1connecting to ::1 when ipv6 was disabled would not fail immediately but
> would have to wait a while.  With your patch applied I am not seeing
> that behavior either.
>
> Tomorrow I should know if I see any weird side effects with your patch,
> after my regression tests for everything else have finished running.

I have to admit I am seeing weird side effects.  A test that was
mysteriously failing because it could not create a vlan on top of a tap
device has started working again ;)

So this change is looking really good for me.

I have to track through some additional failures that I think are test
bugs, but it looks like I might finally have 2.6.37 in a shape where I
can use it.

Eric
