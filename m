From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [PATCH iproute2 3/3] ip netns: Delete all netns
Date: Fri, 9 Jan 2015 11:54:46 +0200
Message-ID: <CAMw6YJLx0O6dVnD2XcmF+qz+=m51TyZOqJWSYGKQ-XrMHP8z3w@mail.gmail.com>
References: <1420628662-9930-1-git-send-email-vadim4j@gmail.com>
	<1420628662-9930-4-git-send-email-vadim4j@gmail.com>
	<54AD5458.6000400@hp.com>
	<20150107173640.GA19586@angus-think.lan>
	<20150107181112.GA24241@angus-think.lan>
	<54AD8BC3.2070609@hp.com>
	<20150107195517.GA4645@angus-think.lan>
	<20150109094315.0c370971@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brian Haley <brian.haley@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	vadim kochan <vadim4j@gmail.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:41803 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbbAIJys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 04:54:48 -0500
Received: by mail-wg0-f49.google.com with SMTP id n12so7164110wgh.8
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 01:54:47 -0800 (PST)
In-Reply-To: <20150109094315.0c370971@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ok,

If I will re-work to use new option, would it be useful ? So it will look:

    $ ip -all netns del
    $ ip -all netns exec ip link
    $ ip -all netns exec ip route add ...

Seems not so weird to me ?

Thanks,

On Fri, Jan 9, 2015 at 10:43 AM, Jiri Benc <jbenc@redhat.com> wrote:
> On Wed, 7 Jan 2015 21:55:17 +0200, Vadim Kochan wrote:
>> On Wed, Jan 07, 2015 at 02:40:51PM -0500, Brian Haley wrote:
>> > Or you just trap the name "all" in the add case and don't allow it.
>>
>> So I think that do not allow to add netns "all" can be a solution, I'd
>> like to hear from other people if it might be OK.
>
> You can still add the name manually (there is software out there that
> adds symlinks to /ver/run/netns), so nope, that's not a solution.
>
> Generally, the only special names that could be used would be those
> containing a letter not allowed in file name, i.e. \0 or '/'. Neither
> of those sounds thrilling. I'm afraid the only working solution is a
> new option.
>
>  Jiri
>
> --
> Jiri Benc
