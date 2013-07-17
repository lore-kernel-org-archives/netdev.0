From: Fernando Soto <fernando.soto@gmail.com>
Subject: Re: WARNING: at net/core/dst.c:274 dst_release+0x2d/0x56()
Date: Wed, 17 Jul 2013 09:19:33 -0400
Message-ID: <CADCFf2jzs+41uKD9RjotXpqSRDoJnSFY90LVKt2UeQfUF05Wrg@mail.gmail.com>
References: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
	<1372799622.4979.22.camel@edumazet-glaptop>
	<CADCFf2hEzwgtqfn4nHc4VwgT2+_XW9=uAos7Qo5YsEpRCWFO5Q@mail.gmail.com>
	<CADCFf2iUeyhnfhHET2Tbi1bM+7h=2LXLFvcerXHsz3Xv6E6zLw@mail.gmail.com>
	<1372950494.4979.97.camel@edumazet-glaptop>
	<CADCFf2gS=m_X2WOVGdgUoKyGgdn1sD9HsBYhjikeMN05RExrOQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:48877 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705Ab3GQNTe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jul 2013 09:19:34 -0400
Received: by mail-ob0-f175.google.com with SMTP id xn12so2234495obc.6
        for <netdev@vger.kernel.org>; Wed, 17 Jul 2013 06:19:33 -0700 (PDT)
In-Reply-To: <CADCFf2gS=m_X2WOVGdgUoKyGgdn1sD9HsBYhjikeMN05RExrOQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

Just to let you know that I have performed same tests with 3.4.52 and
it works fine.
Kernel 3.10 had another issue that prevented me from running the same
tests: network dies as soon as I launch iperf - no kernel errors, but
it simply doesn't work.
I'll stick to 3.4.52. Thanks for your help.

Fernando

On Thu, Jul 4, 2013 at 11:56 AM, Fernando Soto <fernando.soto@gmail.com> wrote:
> I'm planning to run the same tests with 3.10. I'll post results once have them.
> Thanks!
>
> On Thu, Jul 4, 2013 at 11:08 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Thu, 2013-07-04 at 08:21 -0400, Fernando Soto wrote:
>>> Hi Eric,
>>>
>>> Unfortunately the issue is still reproducible after the patch was
>>> applied. Iperf tests were running for almost 24h when it happened:
>>
>> Well, 3.5 is not a stable kernel, did you try a recent version ?
>>
>>
