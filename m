From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH] net: unix: non blocking recvmsg() should not return -EINTR
Date: Wed, 26 Mar 2014 22:51:13 +0000
Message-ID: <871txo7evy.fsf@sable.mobileactivedefense.com>
References: <87zjkd802t.fsf@sable.mobileactivedefense.com>
	<1395847524.12610.208.camel@edumazet-glaptop2.roam.corp.google.com>
	<87y4zw7ngi.fsf@sable.mobileactivedefense.com>
	<20140326.170514.1793472148242469413.davem@davemloft.net>
	<87a9cc7j1o.fsf@sable.mobileactivedefense.com>
	<1395870280.12610.252.camel@edumazet-glaptop2.roam.corp.google.com>
	<8761n07gxy.fsf@sable.mobileactivedefense.com>
	<1395873322.12610.272.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, David.Laight@ACULAB.COM,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tiger.mobileactivedefense.com ([217.174.251.109]:48612 "EHLO
	tiger.mobileactivedefense.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753861AbaCZWv1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 18:51:27 -0400
In-Reply-To: <1395873322.12610.272.camel@edumazet-glaptop2.roam.corp.google.com>
	(Eric Dumazet's message of "Wed, 26 Mar 2014 15:35:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
> On Wed, 2014-03-26 at 22:06 +0000, Rainer Weikusat wrote:
>
>> That would be a seriously bizarre idea. The thread of execution which
>> does the supposed-to-be-non-blocking call shouldn't become blocked for
>> an indefinite time. Which means it should not wait indefinitely for a
>> thread which - in turn - waits indefinitely for an external event (and
>> hence, the original problem should never have existed to begin with as
>> there would neither be an opportunity nor a reason to interrupt in the
>> non-blocking case).
>
>
> This is not what your program do.
>
> Your program does a read() on a blocking fd.

It does both, actually: The forked process calls read while the socket
is still blocking, the other process calls read after it was switched to
non-blocking. This can easily be determined with strace.

Again, please stop dumping your infiltered rage onto me just because I
happen to disagree with you. You won't change that.
