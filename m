From: Rick Jones <rick.jones2@hp.com>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 14:10:17 -0800
Message-ID: <4F1894C9.8060200@hp.com>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net> <20120119.143105.735366189369504929.davem@davemloft.net> <20120119195349.GN2262734@jupiter.n2.diac24.net> <20120119.152752.318442465605898328.davem@davemloft.net> <m1lip32xoi.fsf@fess.ebiederm.org> <20120119214052.GA12249@hell> <20120119214718.GC3347849@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>,
	hans.schillstrom@ericsson.com, netdev@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:40226 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751635Ab2ASWKU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 17:10:20 -0500
In-Reply-To: <20120119214718.GC3347849@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2012 01:47 PM, David Lamparter wrote:
> On Thu, Jan 19, 2012 at 10:40:53PM +0100, Hagen Paul Pfeifer wrote:
>> * Eric W. Biederman | 2012-01-19 13:24:13 [-0800]:
>>
>>> This thread is a fascinating disconnect from reality all of the way
>>> around.
>>>
>>> - inet_twsk_purge already implements throwing out of timewait sockets
>>>   when a network namespaces is being cleaned up.  So the RFC is nonsense.
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

May one actually, safely assume that timestamps are universally in place?

rick jones
suspects that no one stuck to the quiet time in the (more distant) 
timestamp-free past simply because booting took "long enough" anyway...
