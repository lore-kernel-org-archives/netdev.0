From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: via-rhine: Transmit timed out problem
Date: Wed, 4 Jul 2007 11:03:05 +0200
Message-ID: <20070704090305.GA2737@ff.dom.local>
References: <20070622121804.GB14554@zetta.epsmu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, rl@hellgate.ch,
	linux-kernel@vger.kernel.org
To: Kirill Kuvaldin <kuvkir@epsmu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:38711 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759972AbXGDIyk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 04:54:40 -0400
Content-Disposition: inline
In-Reply-To: <20070622121804.GB14554@zetta.epsmu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22-06-2007 14:18, Kirill Kuvaldin wrote:
> Hi,
> 
> I'm experiencing a strange problem with a via rhine network card on Ubuntu 
> 7.04 (2.6.20-16-generic #2 SMP). The hardware seemed to come into an
> inconsistent state, since rmmod'ing and modprobe'ing the via-rhine driver 
> back didn't help. 
> 
> After the problem had appeared, I could see the following in dmesg:
> 
> [ 8601.971189] irq 21: nobody cared (try booting with the "irqpoll"
> option)
> [ 8601.971214]  [<c01543a4>] __report_bad_irq+0x24/0x80
...
> [ 8601.971291] handlers:
> [ 8601.971293] [<f887ff10>] (usb_hcd_irq+0x0/0x60 [usbcore])
> [ 8601.971311] [<f88a7dd0>] (rhine_interrupt+0x0/0xb80 [via_rhine])
> [ 8601.971324] Disabling IRQ #21
...
> The interrupt seemed to be unhandled and got disabled by the kernel
> then. The transmission seemed to time out for some reason (probably, the
> hardware got into an inconsistent state?).
...
> Is that information sufficient for debug? Let me know if you need
> any additional data.

Your diagnose seems right but there are at least 2 suspects.
I doubt I can debug this, but maybe trying this "irqpoll" could
really tell more to somebody.

You could probably try to check this without USB (e.g. with kernel
parameter "nousb"), too.

Regards,
Jarek P.
