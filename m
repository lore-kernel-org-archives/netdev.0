From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Mon, 6 Apr 2009 20:00:25 +0100
Message-ID: <20090406200025.67cc558a@lxorguk.ukuu.org.uk>
References: <200904061430.26276.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Peterson <cpeterso@cpeterso.com>,
	Matt Mackall <mpm@selenic.com>
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:50769 "EHLO
	www.etchedpixels.co.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751854AbZDFTBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2009 15:01:07 -0400
In-Reply-To: <200904061430.26276.rgetz@blackfin.uclinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 6 Apr 2009 14:30:26 -0400
Robin Getz <rgetz@blackfin.uclinux.org> wrote:

> Although there was some discussion  
> http://thread.gmane.org/gmane.linux.kernel/680723
> 
> about removing IRQF_SAMPLE_RANDOM from the remaining network drivers in May of 
> 2008, but they still appears to be there in 2.6.29.

These are mostly unmaintained drivers. Dunno why tg3 isn't fixed - it has
some mitigation logic so maybe its not observable


> I can put a scope/analyser on a device - and look at the touchscreens, serial 
> devices, USB, all without cracking the case. 

But you can observe a network interface accurately from all over the lan
(and with a ten dollar card), or a good deal further (I believe up to 1Km
in the right conditions was claimed by some

If you need absolute hard entropy then use a real entropy source, if not
then your user space is using the wrong device file - the blocking for
entropy one. At that point it depends how vital your SSL is to you and
what it protects.

Alan
