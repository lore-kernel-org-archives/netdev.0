From: Robin Getz <rgetz@blackfin.uclinux.org>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Tue, 7 Apr 2009 17:58:50 -0400
Message-ID: <200904071758.50823.rgetz@blackfin.uclinux.org>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <alpine.DEB.2.00.0904070003470.6968@aurora.sdinet.de> <49DA91C2.1020106@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Sven-Haegar Koch" <haegar@sdinet.de>,
	"Matt Mackall" <mpm@selenic.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Chris Peterson" <cpeterso@cpeterso.com>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nwd2mail10.analog.com ([137.71.25.55]:36436 "EHLO
	nwd2mail10.analog.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932072AbZDGV5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 17:57:39 -0400
In-Reply-To: <49DA91C2.1020106@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon 6 Apr 2009 19:35, Jeff Garzik pondered:
> Sven-Haegar Koch wrote:
> > On Mon, 6 Apr 2009, Matt Mackall wrote:
> > 
> >> On Mon, 2009-04-06 at 14:30 -0400, Robin Getz wrote:
> >>> We have lots of embedded headless systems (no keyboard/mouse, no
> >>> soundcard, no video) systems with *no* sources of entropy - and people
> >>> using SSL. 
> >> I'd rather add a random_sample_network call somewhere reasonably central
> >> in the network stack. Then we can use the knowledge that the sample is
> >> network-connected in the random core to decide how to measure its
> >> entropy. The trouble with IRQF_SAMPLE_RANDOM is that many of its users
> >> are technically bogus as entropy sources in the current model.
> >>
> >> I'm eventually going to move the RNG away from the strict theoretical
> >> entropy accounting model to a more pragmatic one which will be much
> >> happier with iffy entropy sources, but that's a ways off.
> > 
> > Btw, perhaps not the perfect question in this thread:
> > But what should we use to keep servers running without a hardware rng 
> > available and without any external input besides the network?
> > After having ssh and openvpn die because of no random and having 
> > the machines like dead and unreachable for me I use "ln -sf 
> > /dev/urandom /dev/random", but that does not feel so good.
> 
> We see this question every time IRQF_SAMPLE_RANDOM is discussed.
> 
> There is plenty of entropy data available, you just have to look 
> around...  Google around for "EGD", video entropy daemon, audio entropy 
> daemon, etc...
> 
> Even headless servers have entropy sources if you look hard enough.

The original question wasn't headless servers - it was headless, no audio, no 
video, boot from flash, (initrd root file systems), diskless. embedded 
devices.

And few want to load up perl on an embedded device just to gather entropy. :(

-Robin
