From: "Remy Bohmer" <linux@bohmer.net>
Subject: Re: DM9000_IRQ_FLAGS
Date: Thu, 20 Dec 2007 10:54:34 +0100
Message-ID: <3efb10970712200154u4c224071q6f5d5d7bb3bf0aa1@mail.gmail.com>
References: <20071211191823.GD15295@buzzloop.caiaq.de>
	 <3efb10970712111231r29f9fba1l3528d805d1009c52@mail.gmail.com>
	 <20071212134153.GA21510@buzzloop.caiaq.de>
	 <20071220094626.GB9216@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Daniel Mack" <daniel@caiaq.de>, netdev@vger.kernel.org
To: "Ben Dooks" <ben@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.227]:44517 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657AbXLTJyf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 04:54:35 -0500
Received: by wr-out-0506.google.com with SMTP id c49so2325538wra.1
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 01:54:34 -0800 (PST)
In-Reply-To: <20071220094626.GB9216@fluff.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben,

> >
> > Actually, the best way to go is to let the platform resources flags
> > decide about that with something like
> >
> >       resource->flags = IORESOURCE_IRQ | IRQT_RISING;
> >
> > but the dm9000 does not care about them at all. Changing that would also
> > imply modifications to all board support code.
>
> I did have a go at trying to get people to pass the information this
> way, but it seem to be ignored last time I sent it. I can dig out the
> code that converts resource->flags to IRQT_ flags.

I thought this issue was already solved by using set_irq_type() in the
BSP, just like all the other boards do...

Kind Regards,

Remy
