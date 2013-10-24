From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Wed, 23 Oct 2013 20:09:49 -0700
Message-ID: <CAOaVG15indAxBz7E-T+9MK03indiXBa0UhQZ5j6K5DxYP44Mxg@mail.gmail.com>
References: <20131023192954.3dd9c784@nehalam.linuxnetplumber.net>
	<CADVnQymDr2K7z3yfKpW-H3R3W3NP+iuPQF2eMfeyS6dn-szdgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	=?ISO-8859-1?Q?Dave_T=E4ht?= <dave.taht@bufferbloat.net>,
	Netdev <netdev@vger.kernel.org>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f180.google.com ([209.85.128.180]:45154 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753041Ab3JXDJu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 23:09:50 -0400
Received: by mail-ve0-f180.google.com with SMTP id db12so1138687veb.39
        for <netdev@vger.kernel.org>; Wed, 23 Oct 2013 20:09:49 -0700 (PDT)
In-Reply-To: <CADVnQymDr2K7z3yfKpW-H3R3W3NP+iuPQF2eMfeyS6dn-szdgA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 23, 2013 at 7:37 PM, Neal Cardwell <ncardwell@google.com> wrote:
> On Wed, Oct 23, 2013 at 10:29 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
>> In the course of testing routing functionality, I discovered a that the single flow TCP
>> throughput was much worse than expected. At first, it looked like a router problem,
>> or maybe because one end was a FreeBSD system (which has noticeably slower TCP performance).
>> But reducing it down to two systems directly connected over 10G (ixgbe) found the problem.
> ...
>>   4. Do something smarter like a dynamic TCP small queue that adapts.
>
> Yep, Eric made TSQ dynamic a few weeks ago, and mentioned that his
> commit helps a single flow on 10Gbps link:
>
> http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=c9eeec26e32e087359160406f96e0949b3cc6f10
>
> Can you please check the performance in your setup on 3.12-rc4 or newer? :-)
>
> Thanks!
>
> neal

I will check 3.12, but what about users on 3.10 which is the LTS
kernel used by most distros?
