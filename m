From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next 0/8] tou: Transports over UDP - part I
Date: Mon, 20 Jun 2016 08:13:48 -0700
Message-ID: <CALx6S37+o2=Lqzxu_U4QiSvqnq8CjEq5uSpbKVfFfo8r5qD+6g@mail.gmail.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
	<20160617.200947.2078656051211641868.davem@davemloft.net>
	<CALx6S37GuppbknFiGsGxyP8jAX-t8c1=mWxCToKQVA8r8UPeOA@mail.gmail.com>
	<20160619.200741.1114304127682357737.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36339 "EHLO
	mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932878AbcFTPNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2016 11:13:50 -0400
Received: by mail-it0-f52.google.com with SMTP id a5so49311315ita.1
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2016 08:13:50 -0700 (PDT)
In-Reply-To: <20160619.200741.1114304127682357737.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 19, 2016 at 8:07 PM, David Miller <davem@davemloft.net> wrote:
> From: Tom Herbert <tom@herbertland.com>
> Date: Fri, 17 Jun 2016 20:52:55 -0700
>
>> For instance, TFO was put in the Linux several years ago, but it
>> still hasn't been enabled in Android and only fairly recently
>> enabled in iOS.
>
> "Android decided to get locked into a really old kernel for 6+ years"
> is not really a good argument, sorry.
>
> We've already been hurt badly by the poor decisions the Android folks
> have made wrt. the handling of their kernel.
>
The problem is not just with Android. We are also very much dependent
on Windows, IOS, and whole bunch of network device vendors and network
operators to run applications over Internet. At least with Android we
have a path to get changes into the kernel pending the "next rebase".
Windows and IOS are black boxes, the only way we can get changes in is
to deal with their engineering directly (both have solid kernel
engineering, but they still set their own agendas). The situation is
worse with middleboxes. They all over the place on what they are doing
and many take a great deal of liberty with choosing which parts of the
standards to implement-- we have no way to directly influence them.

> Let's not make it worse by also making userland TCP stacks ubiquitous
> as a side effect.
>
> I've been assured several times that the Android situation will at
> the very least improve.
>
> And if it does improve and features do propagate more quickly, we'll
> have all of this risk and gambling unnecessarily.
>
> Let's not route around the Android problem, but rather get them to
> address it properly.

Routing around the problem is already being done. From
draft-tsvwg-quic-protocol-02:

"QUIC operates entirely in userspace, and is currently shipped to
users as a part of the Chromium browser, enabling rapid deployment and
experimentation.  As a userspace transport atop UDP, QUIC allows
innovations which have proven difficult to deploy with existing
protocols as they are hampered by legacy clients and middleboxes, or
by prolonged Operating System development and deployment cycles."

We can't ignore this. We can't just dismiss this as being a impending
failure because it conflicts with our idea of what the architecture of
the Internet should be. We would be remiss if we don't consider
solutions like QUIC or developing competitive alternatives like we're
doing in TOU.

Tom
