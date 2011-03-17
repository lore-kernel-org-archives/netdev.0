From: Andrew Victor <avictor.za@gmail.com>
Subject: Re: [PATCHv2 1/9] at91: provide macb clks with "pclk" and "hclk" name
Date: Thu, 17 Mar 2011 11:22:37 +0200
Message-ID: <AANLkTin9FH2orOaV-6feGDikCGvb3C-Q2CnRzp-Y2S4X@mail.gmail.com>
References: <1300184096-13937-1-git-send-email-jamie@jamieiles.com>
	<1300184096-13937-2-git-send-email-jamie@jamieiles.com>
	<AANLkTimwwUQGhncE7Att_9rAXhpT0n61HC4SW8ShSfAm@mail.gmail.com>
	<20110316083844.GA13262@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nicolas.ferre@atmel.com, Jamie Iles <jamie@jamieiles.com>,
	plagnioj@jcrosoft.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:55113 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890Ab1CQJWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Mar 2011 05:22:38 -0400
Received: by bwz15 with SMTP id 15so2280365bwz.19
        for <netdev@vger.kernel.org>; Thu, 17 Mar 2011 02:22:37 -0700 (PDT)
In-Reply-To: <20110316083844.GA13262@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi Russell,

>> There is no reference to a "pclk" or "hclk" in the AT91 architecture.
>> So to avoid possible confusion, maybe create two "fake" clocks both
>> parented to "macb_clk", and add a comment they're only for
>> compatibility with the AVR32.
>
> It doesn't matter what's in the documentation.
>
> What matters more than conforming to documentation is keeping the drivers
> in a clean and maintainable state without throwing lots of ifdefs into
> them.

I'm not saying the drivers need ifdefs, they should request both
"pclk" and "hclk" as suggested.

What I was suggesting is the platform clock setup on AT91 as:
    macb_clk
        |
        +-- hclk
        +-- pclk

rather than:
    pclk
        |
        +-- hclk

Regards,
  Andrew Victor
