From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Thu, 23 Jun 2016 09:50:50 +0200
Message-ID: <576B94DA.7070804@nod.at>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
 <20160623.034004.1518087003165708123.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.ns.miles-group.at ([95.130.255.144]:44723 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750950AbcFWHu5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 03:50:57 -0400
In-Reply-To: <20160623.034004.1518087003165708123.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 23.06.2016 um 09:40 schrieb David Miller:
> From: Richard Weinberger <richard.weinberger@gmail.com>
> Date: Thu, 23 Jun 2016 00:15:04 +0200
> 
>> On Thu, Jun 16, 2016 at 7:51 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> Transports over UDP is intended to encapsulate TCP and other transport
>>> protocols directly and securely in UDP.
>>>
>>> The goal of this work is twofold:
>>>
>>> 1) Allow applications to run their own transport layer stack (i.e.from
>>>    userspace). This eliminates dependencies on the OS (e.g. solves a
>>>    major dependency issue for Facebook on clients).
>>
>> Facebook on clients would be a Facebook app on mobile devices?
>> Does that mean that the Facebook app is so advanced and complicated
>> that it needs a special TCP stack?!
> 
> No, the TCP stack in the android/iOS/Windows kernel is so out of date
> that in order to get even moderately recent TCP features it is
> necessary to do this.

I see.
So the plan is bringing TOU into almost every kernel out there
and then ship Apps with their own TCP stacks since vendors are unable
to deliver decent updates.

I didn't realize that the situation is *that* worse. :(

Thanks,
//richard
