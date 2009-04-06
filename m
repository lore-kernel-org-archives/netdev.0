From: Sven-Haegar Koch <haegar@sdinet.de>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Tue, 7 Apr 2009 00:09:31 +0200 (CEST)
Message-ID: <alpine.DEB.2.00.0904070003470.6968@aurora.sdinet.de>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <1239044483.14392.55.camel@calx>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Robin Getz <rgetz@blackfin.uclinux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Chris Peterson <cpeterso@cpeterso.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760592AbZDFWUt@vger.kernel.org>
In-Reply-To: <1239044483.14392.55.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 6 Apr 2009, Matt Mackall wrote:

> On Mon, 2009-04-06 at 14:30 -0400, Robin Getz wrote:
> > We have lots of embedded headless systems (no keyboard/mouse, no soundcard, no 
> > video) systems with *no* sources of entropy - and people using SSL.
> 
> I'd rather add a random_sample_network call somewhere reasonably central
> in the network stack. Then we can use the knowledge that the sample is
> network-connected in the random core to decide how to measure its
> entropy. The trouble with IRQF_SAMPLE_RANDOM is that many of its users
> are technically bogus as entropy sources in the current model.
> 
> I'm eventually going to move the RNG away from the strict theoretical
> entropy accounting model to a more pragmatic one which will be much
> happier with iffy entropy sources, but that's a ways off.

Btw, perhaps not the perfect question in this thread:
But what should we use to keep servers running without a hardware rng 
available and without any external input besides the network?
After having ssh and openvpn die because of no random and having 
the machines like dead and unreachable for me I use "ln -sf 
/dev/urandom /dev/random", but that does not feel so good.

c'ya
sven

-- 
The lights are fading out, once more...
