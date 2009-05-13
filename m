From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] [resend] drivers/net: remove network drivers' last few
 uses of IRQF_SAMPLE_RANDOM
Date: Wed, 13 May 2009 15:39:11 -0400
Message-ID: <4A0B21DF.9050702@garzik.org>
References: <alpine.DEB.2.00.0905130118140.15823@ubuntu-desktop> <20090513060850.GZ31071@waste.org> <a24804730905130017t545b7645x71ab7a1c8ab4af78@mail.gmail.com> <20090513142535.GB31071@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Chris Peterson <cpeterso@cpeterso.com>,
	linux-kernel@vger.kernel.org, NetDev <netdev@vger.kernel.org>
To: Matt Mackall <mpm@selenic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57321 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755452AbZEMTjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 15:39:16 -0400
In-Reply-To: <20090513142535.GB31071@waste.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Mackall wrote:
> On Wed, May 13, 2009 at 12:17:29AM -0700, Chris Peterson wrote:
>>> The future model will continue to sample network
>>> devices on theory that they -might- be less than 100% observable and
>>> that can only increase our total (unmeasurable) amount of entropy.
>> That sounds reasonable to me. So should all net drivers now specify
>> IRQF_SAMPLE_RANDOM?
>>
>> Or even simpler: could request_irq() assume IRQF_SAMPLE_RANDOM for any
>> interrupt that is not (say) IRQF_IRQPOLL or IRQF_PERCPU?
> 
> Maybe. We don't want IRQ latency to suffer. So before we turn on
> sampling of -all- sources, we need to make sampling lighter weight and
> we need a way to say 'we have enough' so that we're not consuming CPU
> when our pools are 'full'. We could turn it on now and rely on the
> current trickle logic, but it's nice to have the water main off when
> doing significant plumbing.

So, until such time, let's be consistent in net driver land and not 
IRQF_SAMPLE_RANDOM.

	Jeff




