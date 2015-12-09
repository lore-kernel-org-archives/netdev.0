From: Tom Herbert <tom@herbertland.com>
Subject: Re: Checksum offload queries
Date: Wed, 9 Dec 2015 14:51:42 -0800
Message-ID: <CALx6S34ns4e_zNzGT6wa9Un7v+P1BiY62UaDCTmS2NeQ_BpBQg@mail.gmail.com>
References: <5665A848.9010001@solarflare.com>
	<20151207.143848.2158761076110518741.davem@davemloft.net>
	<5666EC4B.40800@solarflare.com>
	<CALx6S36aMvroE0mWz9+9EU+newrfkUqqFO+6T5YZVh_9xrMJLg@mail.gmail.com>
	<20151209015602.GB19097@pox.localdomain>
	<CALx6S37Dw_reYPXd9_4wCTO+BMqwQrvfMfEWDD7XCToODmm=rg@mail.gmail.com>
	<20151209222924.GG11201@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Cree <ecree@solarflare.com>,
	David Miller <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:35029 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753527AbbLIWvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 17:51:43 -0500
Received: by ioc74 with SMTP id 74so76147018ioc.2
        for <netdev@vger.kernel.org>; Wed, 09 Dec 2015 14:51:42 -0800 (PST)
In-Reply-To: <20151209222924.GG11201@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 9, 2015 at 2:29 PM, Thomas Graf <tgraf@suug.ch> wrote:
> On 12/09/15 at 08:08am, Tom Herbert wrote:
>> On Tue, Dec 8, 2015 at 5:56 PM, Thomas Graf <tgraf@suug.ch> wrote:
>> > If I understood Edward correctly, his proposal would be for the
>> > card to provide both, the csum as for CHECKSUM_COMPLETE plus the
>> > validation yes/no hint. It would be up to the kernel to decide
>> > whether to validate itself or trust the card.
>> >
>> > I'm all in favour CHECKSUM_COMPLETE as the only way to go but
>> > we should be aware that it depends on the penetration of RCO in
>> > hardware VTEPs.
>>
>> Thomas, I don't understand what you are saying here. CHECKSUM_COMPLETE
>> is an interface for drivers providing the computed checksum of a
>> packet on receive, how is this dependent on any use case or any other
>> mechanisms?
>
> I'm referring to the overall change which comes with a pure
> CHECSUM_COMPLETE model which would forbid a NIC to do automatic nested
> checksum filling even if untold. RCO solves that to some extent but
> only if RCO is widely supported. I'm not aware of anybody relying on
> the performance of such hardware yet so I doubt we would create a
> performance regression.
>
I'm sorry, I still don't understand your point. What is "automatic
nested  checksum filling" and how does this relate to RX (e.g.
CHECSUM_COMPLETE).
