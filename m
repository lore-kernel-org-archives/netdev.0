From: Ondrej Zary <linux@rainbow-software.org>
Subject: Re: Compex FreedomLine 32 PnP-PCI2 broken with de2104x
Date: Mon, 25 Feb 2008 22:31:25 +0100
Message-ID: <200802252231.27081.linux@rainbow-software.org>
References: <200801262158.12016.linux@rainbow-software.org> <20080218032111.GA7970@colo.lackof.org> <47C26E0E.2070109@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Grant Grundler <grundler@parisc-linux.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atlantis.sk ([80.94.52.35]:41781 "EHLO mail.atlantis.sk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752099AbYBYVbe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 16:31:34 -0500
In-Reply-To: <47C26E0E.2070109@pobox.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 25 February 2008 08:28:14 Jeff Garzik wrote:
> Grant Grundler wrote:
> > ISTR there was a time when tulip would compete with de4x5 for devices.
> > tulip is the preferred driver. That's clearly no longer the case
> > and perhaps both distro's need to revisit this.
>
> The only reason why de4x5 still exists is that the /tulip/ driver fails
> to work on a few chips like the 21142 (43?) shipped in various alpha boxen.
>
> de4x5 needs to go away, it's been unmaintained for ages, doesn't support
> any of the new hotplug APIs.

But has extensive port auto-detection which seems to work great (at least on 
my card). I don't feel like porting that code to de2104x - the code looks 
complex.

>
> > de2104x is a "work in progress".
> > That's why it's marked "EXPERIMENTAL" in the Kconfig file.
>
> It's not a work in progress, it works just fine for most people (the few
> that are left).
>
> Last I heard, there was a problem with non-twisted-pair stuff, but
> that's about it.
>
> 'experimental' is generally a poorly maintained marker.

So we have two unmaintained drivers - one that works fine (and is production 
quality - or at least seems to be) but does not support hotplug APIs and one 
that was never finished (the TP-unplug problem is present at least since 
2003).
Perhaps de4x5 could be ported to new API(s)? I think that it's much easier 
than fixing obscure hardware-related problems like cable auto-detection.

-- 
Ondrej Zary
