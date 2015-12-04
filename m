From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Fri, 4 Dec 2015 12:13:53 -0800
Message-ID: <CALx6S349Ub+UJSRN5UEt+0b76sVLzcxDbq_hZGaKkRzK-_gOrw@mail.gmail.com>
References: <1449158374.11080.456996721.69F803D7@webmail.messagingengine.com>
	<CALx6S342OMLB6s7LcmnZP1rnYNUs345Dy1gjYX3JUKqqB_waPA@mail.gmail.com>
	<1449259145.6236.458303617.55CF2C4E@webmail.messagingengine.com>
	<20151204.150633.1744714566987717806.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:37009 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912AbbLDUNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2015 15:13:54 -0500
Received: by igcto18 with SMTP id to18so44138408igc.0
        for <netdev@vger.kernel.org>; Fri, 04 Dec 2015 12:13:54 -0800 (PST)
In-Reply-To: <20151204.150633.1744714566987717806.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 4, 2015 at 12:06 PM, David Miller <davem@davemloft.net> wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Fri, 04 Dec 2015 20:59:05 +0100
>
>> Yes, I agree, I am totally with you here. If generic offloading can be
>> realized by NICs I am totally with you that this should be the way to
>> go. I don't see that coming in the next (small number of) years, so I
>> don't see a reason to stop this patchset.
>
> If I just apply this and say "yeah ok", the message is completely lost
> and your prediction about "small number of years" indeed will occur.
>
> However if I push back hard on this, as I will, then the message has
> some chance of seeping back to the people designing these chips.
>
> So that's what I'm going to do, like it or not.
>
> Or can someone convince me that someone who understand this stuff
> is telling the hardware guys to universally put 2's complement
> checksums into the descriptors?
>
We're talking about 1's complement checksum (RFC1701). Just to be clear :-)
