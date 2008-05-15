From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] drivers/net: remove network drivers' last few uses of
 IRQF_SAMPLE_RANDOM
Date: Thu, 15 May 2008 18:42:06 -0400
Message-ID: <482CBC3E.8060305@garzik.org>
References: <Pine.LNX.4.62.0805150009060.18303@ikari.dreamhost.com> <20080515142154.0595e475@core> <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Chris Peterson <cpeterso@cpeterso.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36902 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753916AbYEOWmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2008 18:42:11 -0400
In-Reply-To: <36D9DB17C6DE9E40B059440DB8D95F52052D71BB@orsmsx418.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brandeburg, Jesse wrote:
> we've been hearing rumblings of big customers wanting (maybe requiring)
> wired network drivers from Intel to  advertise this flag.  Jeff have you
> heard of such?
> 
> I think the argument is that a headless system (no keyboard/mouse, no
> soundcard, probably no video) with a libata based driver and a network
> driver without IRQF_SAMPLE_RANDOM has *no* sources of entropy.  In this
> case the argument is very strong for at least *some* source of entropy
> from interrupts so that randomness can get some external input.  Just
> try rebuilding a kernel RPM over an ssh session and you'll see what I
> mean.
> 
> In short, I agree with Alan's IRQF_SAMPLE_DUBIOUS, and know of Linux
> customers who also want the same.


So I guess a good message for customers might be:

Don't depend on an entropy source whose volume decreases as workload and 
network traffic increase.

	Jeff


