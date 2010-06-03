From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH v2] netfilter: Xtables: idletimer target implementation
Date: Thu, 3 Jun 2010 09:58:27 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006030956000.9308@obet.zrqbmnf.qr>
References: <1275486062-23753-1-git-send-email-luciano.coelho@nokia.com>  <alpine.LSU.2.01.1006021708370.27340@obet.zrqbmnf.qr>  <1275503835.1574.0.camel@powerslave> <1275505553.2797.2.camel@powerslave>  <alpine.LSU.2.01.1006022127430.32028@obet.zrqbmnf.qr>
  <1275508348.2797.26.camel@powerslave> <1275509088.2797.29.camel@powerslave>  <1275512485.2797.46.camel@powerslave> <1275548660.10855.4.camel@chilepepper>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"kaber@trash.net" <kaber@trash.net>, Timo Teras <timo.teras@iki.fi>
To: Luciano Coelho <luciano.coelho@nokia.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1275548660.10855.4.camel@chilepepper>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Thursday 2010-06-03 09:04, Luciano Coelho wrote:
>
>Looking closer, it seems that it makes a bit of sense to add a kernel
>module to /sys/device/system.  I think it makes more sense than adding
>to the module class or to the net class, actually.  The idletimer is not
>a net device (so it doesn't fit in /sys/class/net) and it is not a
>module, even though it may be handled by the xt_IDLETIMER module.
>
>So we can look at the xt_idletimer as a system device, which is not a
>peripheral device in itself, but a software timer device (there are
>already similar components).
>
>I'll add the kernel object we need as a system class device, so it will
>go under /sys/devices/system/xt_idletimer.  Does that make sense to you?

Mh.. somehow I'd pick /sys/devices/virtual/xt_idletimer.
Or even create a /sys/net/xt_idletimer. (/sys has conceptual
subsystems directly beneath it: devices, fs, kernel, ...)
