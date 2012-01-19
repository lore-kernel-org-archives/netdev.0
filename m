From: David Miller <davem@davemloft.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 17:37:13 -0500 (EST)
Message-ID: <20120119.173713.2180573303386307668.davem@davemloft.net>
References: <m1lip32xoi.fsf@fess.ebiederm.org>
	<20120119214052.GA12249@hell>
	<20120119214718.GC3347849@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hagen@jauu.net, ebiederm@xmission.com,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51577 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab2ASWjE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 17:39:04 -0500
In-Reply-To: <20120119214718.GC3347849@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Thu, 19 Jan 2012 22:47:18 +0100

> On Thu, Jan 19, 2012 at 10:40:53PM +0100, Hagen Paul Pfeifer wrote:
>> * Eric W. Biederman | 2012-01-19 13:24:13 [-0800]:
>> 
>> >This thread is a fascinating disconnect from reality all of the way
>> >around.
>> >
>> >- inet_twsk_purge already implements throwing out of timewait sockets
>> >  when a network namespaces is being cleaned up.  So the RFC is nonsense.
>> 
>> This is how it is implemented, not how it should be. TIME_WAIT is not the
>> problem, it is there to keep the stack from sending wrong RST messages. Maybe
>> the 2*MSL could be fixed by a more accurate 2*RTT.
> 
> I may have made that argument hidden behind a joke, but please refer to
> the development of RFC 793's bootup "quiet time". The reason no one
> sticks to this quiet time is that TCP timestamps have obsoleted it by
> providing a better frame of reference. Refer to RFC 1323 Appendix B
> "DUPLICATES FROM EARLIER CONNECTION INCARNATIONS".

I recommend you go and see what percentage of TCP connections actually
have timestamps enabled, you might be surprised.  I believe there are
some good up to date figures in the google TCP papers.
