From: Yann Ylavic <ylavic.dev@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 25 Mar 2016 12:21:35 +0100
Message-ID: <CAKQ1sVMpwjegwvW1vcJKq+wRwqY0XMP_SS_LWhzc=UZq5yDcoA@mail.gmail.com>
References: <20160324165047.GA7585@1wt.eu>
	<1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
	<56F42A00.7050002@iogearbox.net>
	<CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
	<1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAKQ1sVPJoaaf1gRfgYPRygfMFVqk08Q0K74wn6kLHV+vy=8w1w@mail.gmail.com>
	<CALx6S37uZah89sNgH9wuD1J+_WEhd34Z5zmrnG8Qp-AQ7Ew=Jg@mail.gmail.com>
	<20160325052819.GA8548@1wt.eu>
	<1458888581.6473.30.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160325085338.GB8655@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:34992 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127AbcCYLVg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 07:21:36 -0400
Received: by mail-qg0-f67.google.com with SMTP id c67so6260663qgc.2
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 04:21:36 -0700 (PDT)
In-Reply-To: <20160325085338.GB8655@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 9:53 AM, Willy Tarreau wrote:
>
> On Thu, Mar 24, 2016 at 11:49:41PM -0700, Eric Dumazet wrote:
>> Everything is possible, but do not complain because BPF went in the
>> kernel before your changes.
>
> Don't get me wrong, I'm not complaining, I'm more asking for help to
> try to elaborate the alternate solution. I understood well what my
> proposal did because it was pretty straightforward, and the new one
> I'll have to do is of an immense complexity for me by now, since it
> will require learning a new language and finding doc on how all this
> works together. But as I said I'm totally sold to the benefits it can
> provide for large scale deployments and I'm well aware of the ugly
> socket scan there was in the previous one.

+1 (all the work done on the listeners, including SO_REUSEPORT, and
until lately very much appreciated in any case!)

>
> If you could share a pointer to some good starter documentation for this,
> I would appreciate it. I really have no idea where to start from and the
> only elements I found on the net didn't give a single hint regarding all
> this :-/

+1

On Fri, Mar 25, 2016 at 1:24 AM, David Miller wrote:
>
> If we encapsulate this into libraries and helper wrappers, there is
> no reason web server developers should be looking at these details
> anyways.

++1

>
> Please don't make a mountain out of a mole-hill.

Not my intention, you guys know what's the better for the kernel and its APIs.
My concern is (was) admittedly due to my own lack of knowledge of
(e)BPF, hence how much of kernel internals I'd need to know to make
the SO_REUSEPORT work in my case.

But sure, any of the help suggested above would make it go away, I'll
stay tuned.
