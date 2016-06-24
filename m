From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Fri, 24 Jun 2016 14:12:15 -0700
Message-ID: <CALx6S35ii7nF0s9n2ocpvNcjo25uDHd+788X+3oTqc4sd1SjOQ@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
 <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
 <20160623.034004.1518087003165708123.davem@davemloft.net> <576B94DA.7070804@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f42.google.com ([209.85.214.42]:38582 "EHLO
	mail-it0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbcFXVMR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2016 17:12:17 -0400
Received: by mail-it0-f42.google.com with SMTP id h190so23843668ith.1
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 14:12:17 -0700 (PDT)
In-Reply-To: <576B94DA.7070804@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 12:50 AM, Richard Weinberger <richard@nod.at> wrote:
> Am 23.06.2016 um 09:40 schrieb David Miller:
>> From: Richard Weinberger <richard.weinberger@gmail.com>
>> Date: Thu, 23 Jun 2016 00:15:04 +0200
>>
>>> On Thu, Jun 16, 2016 at 7:51 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>> Transports over UDP is intended to encapsulate TCP and other transport
>>>> protocols directly and securely in UDP.
>>>>
>>>> The goal of this work is twofold:
>>>>
>>>> 1) Allow applications to run their own transport layer stack (i.e.from
>>>>    userspace). This eliminates dependencies on the OS (e.g. solves a
>>>>    major dependency issue for Facebook on clients).
>>>
>>> Facebook on clients would be a Facebook app on mobile devices?
>>> Does that mean that the Facebook app is so advanced and complicated
>>> that it needs a special TCP stack?!
>>
>> No, the TCP stack in the android/iOS/Windows kernel is so out of date
>> that in order to get even moderately recent TCP features it is
>> necessary to do this.
>
> I see.
> So the plan is bringing TOU into almost every kernel out there
> and then ship Apps with their own TCP stacks since vendors are unable
> to deliver decent updates.
>
> I didn't realize that the situation is *that* worse. :(
>
The client OS side is only part of the story. Middlebox intrusion at
L4 is also a major issue we need to address. The "failure" of TFO is a
good case study. Both the upgrade issues on clients and the tendency
for some middleboxes to drop SYN packets with data have together
severely hindered what otherwise should have been straightforward and
useful feature to deploy.

Tom

> //richard
