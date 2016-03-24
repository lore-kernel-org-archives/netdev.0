From: Tolga Ceylan <tolga.ceylan@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Thu, 24 Mar 2016 11:20:49 -0700
Message-ID: <CALmu+SxF5dDEBwpk-R=V5DGZBed1rvjYGEJ+cU8ZhyAdLWshug@mail.gmail.com>
References: <20151219070009.GA4634@1wt.eu>
	<CALx6S35248apbWqtG+g2U99O=4UJqyAG0bJeuxhZWtShrpDF+w@mail.gmail.com>
	<20151221204127.GC8018@1wt.eu>
	<CALmu+SwjG0GVocGufTbgX-WJfcsP85SvHB=xtW7qQX3kZwJCxg@mail.gmail.com>
	<20160324061222.GA6807@1wt.eu>
	<1458828813.10868.65.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324142222.GB7237@1wt.eu>
	<1458830744.10868.72.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324153053.GA7569@1wt.eu>
	<1458837191.12033.4.camel@edumazet-glaptop3.roam.corp.google.com>
	<20160324165047.GA7585@1wt.eu>
	<1458838897.12033.10.camel@edumazet-glaptop3.roam.corp.google.com>
	<CALx6S36Ej1es8qFi2Q3=199f+rmG=Za02N5ZBWT5DCRqrBEWvQ@mail.gmail.com>
	<56F42A00.7050002@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Willy Tarreau <w@1wt.eu>, Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:34567 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250AbcCXSUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 14:20:50 -0400
Received: by mail-io0-f170.google.com with SMTP id m184so92857303iof.1
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 11:20:49 -0700 (PDT)
In-Reply-To: <56F42A00.7050002@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 24, 2016 at 10:55 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 03/24/2016 06:26 PM, Tom Herbert wrote:
>>
>> I completely agree with this, but I wonder if we now need a repository
>> of useful BPF modules. So in the case of implementing functionality
>> like in SO_REUSEPORT_LISTEN_OFF that might just become a common BPF
>> program we could direct people to use.
>
>
> Good point. There's tools/testing/selftests/net/ containing already
> reuseport
> BPF example, maybe it could be extended.

I would appreciate a conceptual description on how this would work
especially for a common scenario
as described by Willy. My initial impression was that a coordinator
(master) process takes this
responsibility to adjust BPF filters as children come and go.

Two popular software has similar use cases: nginx and haproxy. Another
concern is with the
introduction of BPF itself, should we expect a performance drop in
these applications?

Best Regards,
Tolga Ceylan
