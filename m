From: Risto Suominen <risto.suominen@gmail.com>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
	coherence
Date: Mon, 9 Feb 2009 21:22:03 +0200
Message-ID: <46e1c7760902091122m6ec7fbb5nefd9cc9789880c0f@mail.gmail.com>
References: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
	 <46e1c7760902082327s1c498ac3w56939960ac306426@mail.gmail.com>
	 <20090208.234502.197065045.davem@davemloft.net>
	 <46e1c7760902090022g1d903ca0nf314f0c1cc6b07c8@mail.gmail.com>
	 <m3vdrja6oe.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:41788 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754127AbZBITWF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 14:22:05 -0500
Received: by bwz5 with SMTP id 5so1747375bwz.13
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2009 11:22:03 -0800 (PST)
In-Reply-To: <m3vdrja6oe.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/2/9 Krzysztof Halasa <khc@pm.waw.pl>:
>
> That means the consistent/coherent mapping isn't really
> consistent/coherent (uncached), right? Perhaps there is some way to fix
> this instead of changing the drivers to avoid the problematic area?
>
Yes.

The other way could be to add a config parameter that allows to
explicitly set CONFIG_NOT_COHERENT_CACHE. I have not tried this,
probably because the necessary code wasn't in arch/powerpc until
2.6.21.

Anyway, now I have tested with 2.6.24, and the problem still exists.

Apropos changing the driver, I would like to point out, that leaving
my proposed config parameter to its default value means not changing
the driver.

> Potentially any driver is affected by such coherency problem, this can't
> be specific to 21040.
>
I agree. That talks for the config solution.

Risto
