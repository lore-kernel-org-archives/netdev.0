From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 16/17] get rid of the size argument of sock_sendmsg()
Date: Wed, 15 Apr 2015 12:06:38 -0400 (EDT)
Message-ID: <20150415.120638.1390441568056166764.davem@davemloft.net>
References: <20150414163534.GZ889@ZenIV.linux.org.uk>
	<20150414.135535.190405308746783212.davem@davemloft.net>
	<063D6719AE5E284EB5DD2968C1650D6D1CB1E7FD@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbbDOQGm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 12:06:42 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CB1E7FD@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Wed, 15 Apr 2015 08:37:01 +0000

> From: David Miller
>> Sent: 14 April 2015 18:56
>> > On Tue, Apr 14, 2015 at 04:25:24PM +0000, David Laight wrote:
>> >> From: Al Viro
>> >> > Sent: 11 April 2015 22:18
>> >> > it's equal to iov_iter_count(&msg->msg_iter) in all cases
>> >>
>> >> I don't know whether this is guaranteed for iov[] that come from
>> >> userspace.
>> >>
>> >> In any case iov_iter_count() is non-trivial and you don't
>> >> really want to call it when unnecessary.
>> >
>> > Really?
>> >
>> > static inline size_t iov_iter_count(struct iov_iter *i)
>> > {
>> >         return i->count;
>> > }
>> 
>> This just made my day.
> 
> I hate accessor functions

I hate people who jump to conclusions and don't actually read the code
in question before commenting. :-)
