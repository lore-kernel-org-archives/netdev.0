From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: [Uclinux-dist-devel] [PATCH 1/5] netdev: bfin_mac: Blackfin EMAC
	interrupt may not be shared
Date: Fri, 29 May 2009 07:22:05 -0400
Message-ID: <8bd0f97a0905290422x502d6006yb05ebe231b05e9bc@mail.gmail.com>
References: <8bd0f97a0905290349p6f52d170i3714cd3ec0c81817@mail.gmail.com>
	 <20090529.035344.92579416.davem@davemloft.net>
	 <8A42379416420646B9BFAC9682273B6D0B43DCCD@limkexm3.ad.analog.com>
	 <20090529.041435.163819214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Michael.Hennerich@analog.com, netdev@vger.kernel.org,
	uclinux-dist-devel@blackfin.uclinux.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:11000 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982AbZE2LWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 07:22:04 -0400
Received: by yw-out-2324.google.com with SMTP id 5so3400766ywb.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2009 04:22:05 -0700 (PDT)
In-Reply-To: <20090529.041435.163819214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 29, 2009 at 07:14, David Miller wrote:
> From: "Hennerich, Michael" <Michael.Hennerich@analog.com>
>> Our handler isn't prepared to handle such fake interrupts.
>> So two options:
>> 1) Set the proper IRQF flags.
>> 2) Fix the ISR to handle spurious interrupts.
>>
>> This patch chose option 1)
>
> And to go back to my initial reply, I'm saying to do the
> "right thing" and go with #2 if you can :-)

and the answer is that doesnt make sense.  why implement extra over
head in an interrupt handler to support an operating mode the hardware
can never support.  if the IRQ could actually be shared, then sure, we
should check things.  but it cant, so you're suggesting we waste time
in an IRQ handler for absolutely no gain.
-mike
