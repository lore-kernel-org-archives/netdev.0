From: Yann Ylavic <ylavic.dev@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 25 Mar 2016 01:01:06 +0100
Message-ID: <CAKQ1sVNHUMzUtrErEVkbr+TYfjnjOPNPzUY0czCkza=AW6hpkg@mail.gmail.com>
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
	<CAKQ1sVP_bbGYnVW=9WDnuzJ7qcC1xrM3qmeYFk-c3fi696F5-g@mail.gmail.com>
	<1458859788.6473.2.camel@edumazet-glaptop3.roam.corp.google.com>
	<CAKQ1sVPJoaaf1gRfgYPRygfMFVqk08Q0K74wn6kLHV+vy=8w1w@mail.gmail.com>
	<CALx6S37uZah89sNgH9wuD1J+_WEhd34Z5zmrnG8Qp-AQ7Ew=Jg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Tolga Ceylan <tolga.ceylan@gmail.com>,
	Craig Gallek <cgallek@google.com>,
	Josh Snyder <josh@code406.com>,
	Aaron Conole <aconole@bytheb.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:36101 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828AbcCYABH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Mar 2016 20:01:07 -0400
Received: by mail-qg0-f67.google.com with SMTP id 14so5343563qgg.3
        for <netdev@vger.kernel.org>; Thu, 24 Mar 2016 17:01:06 -0700 (PDT)
In-Reply-To: <CALx6S37uZah89sNgH9wuD1J+_WEhd34Z5zmrnG8Qp-AQ7Ew=Jg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 12:54 AM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Mar 24, 2016 at 4:40 PM, Yann Ylavic <ylavic.dev@gmail.com> wrote:
>>
>> From this POV, draining the (ending) listeners is already non obvious
>> but might be reasonable, (e)BPF sounds really overkill.
>>
> Just the opposite, it's a simplification. With BPF we no longer to add
> interfaces for all these special cases. This is an important point,
> because the question is going to be raised for any proposed interface
> change that could be accomplished with BPF (i.e. adding new interfaces
> in the kernel becomes the overkill).
>
> Please try to work with it. As I mentioned, the part that we may be
> missing are some real world programs that we can direct people to use,
> but aside from that I don't think we've seen any arguments that BPF is
> overkill or too hard to use for stuff like this.

OK, you certainly know better than me.
Really looking forward these real world BPF programs to enlighten me.

Thanks for your time.

Regards,
Yann.
