From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Wed, 22 Jun 2016 15:56:19 -0700
Message-ID: <CALx6S35V+ddd_-Yp29renRTsA=_0h_raqE5RZHGv-uobXm9K4w@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com> <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:36515 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbcFVW4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 18:56:21 -0400
Received: by mail-io0-f169.google.com with SMTP id s63so53197039ioi.3
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 15:56:20 -0700 (PDT)
In-Reply-To: <CAFLxGvwmhTv0rTuDpg7r1vZ0GEU93j1QxV12mJ2c2W2qSJGRCQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 3:15 PM, Richard Weinberger
<richard.weinberger@gmail.com> wrote:
> On Thu, Jun 16, 2016 at 7:51 PM, Tom Herbert <tom@herbertland.com> wrote:
>> Transports over UDP is intended to encapsulate TCP and other transport
>> protocols directly and securely in UDP.
>>
>> The goal of this work is twofold:
>>
>> 1) Allow applications to run their own transport layer stack (i.e.from
>>    userspace). This eliminates dependencies on the OS (e.g. solves a
>>    major dependency issue for Facebook on clients).
>
> Facebook on clients would be a Facebook app on mobile devices?
> Does that mean that the Facebook app is so advanced and complicated
> that it needs a special TCP stack?!
>
Yes, in the sense that Facebook app is probably the biggest single app
in mobile and probably has about the most users. Advancing the
transport layer, especially with regards to security and privacy, is
critical to maintain long term viability. But that being said,
security, protocol ossification, middlebox intrusion, the demise of
the E2E model are everyone's problem. One major issue here, probably
the biggest issue on the whole Internet, is that upgrade story for
core software (FW, OS, etc.) in devices attached to the Internet is
miserable-- to the point that some people think this undermines the
future of the Internet (e.g.
http://www.darkreading.com/vulnerabilities---threats/internet-of-things-devices-are-doomed/d/d-id/1315735).
TOU is a means to eliminate the dependencies we have on devices or
OSes being secure or being updated in a timely fashion to provide
security improvements.

Tom

> --
> Thanks,
> //richard
