From: Risto Suominen <risto.suominen@gmail.com>
Subject: Re: [PATCH 002/002] de2104x: support for systems lacking cache
	coherence
Date: Tue, 10 Feb 2009 09:16:06 +0200
Message-ID: <46e1c7760902092316g432a432dy10398030a5838ba9@mail.gmail.com>
References: <46e1c7760902071330i5362fe4fvd99fc7075fc666d3@mail.gmail.com>
	 <20090209170120.85e192be.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Grant Grundler <grundler@parisc-linux.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:41559 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1749667AbZBJHQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 02:16:09 -0500
In-Reply-To: <20090209170120.85e192be.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/2/10 Andrew Morton <akpm@linux-foundation.org>:
>
> Please prefer to prepare patches in `patch -p1' form:
>
> --- a/drivers/net/tulip/Kconfig
> +++ a/drivers/net/tulip/Kconfig
>
I'll try to remember that.

> I think CONFIG_DE2104X_DSL is always defined if this driver is being
> compiled.  So the Kconfig `default' should suffice here?  In which case
> we can do
>
> #define DSL CONFIG_DE2104X_DSL
>
> and leave it at that.
>
> In which case we can do away with DSL everywhere and just use
> CONFIG_DE2104X_DSL here.
>
I was thinking of the case where someone just compiles without reconfiguring.

> But really, we shouldn't do this at configuration time at all.  It
> would be much better to do it at runtime, via a module parameter.
>
Well, yeah, but that would probably cost cpu cycles. At least it would
mean lots of changes.

> And it would be much^2 better to do it automatically, based upon the
> chip probing information or whatever.  That's probably hard.
>
I agree.

> Can remove the ifdefs here.  A zero-length array is OK, and will
> consume zero space.
>
I was uncertain whether this applies to all compilers. I kind of
remember opposite cases in the past.

Risto
