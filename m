From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Compex FreedomLine 32 PnP-PCI2 broken with de2104x
Date: Mon, 25 Feb 2008 02:28:14 -0500
Message-ID: <47C26E0E.2070109@pobox.com>
References: <200801262158.12016.linux@rainbow-software.org> <200801302123.07783.linux@rainbow-software.org> <20080218032111.GA7970@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ondrej Zary <linux@rainbow-software.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47661 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750909AbYBYH2g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 02:28:36 -0500
In-Reply-To: <20080218032111.GA7970@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grant Grundler wrote:
> ISTR there was a time when tulip would compete with de4x5 for devices.
> tulip is the preferred driver. That's clearly no longer the case
> and perhaps both distro's need to revisit this.

The only reason why de4x5 still exists is that the /tulip/ driver fails 
to work on a few chips like the 21142 (43?) shipped in various alpha boxen.

de4x5 needs to go away, it's been unmaintained for ages, doesn't support 
any of the new hotplug APIs.


> de2104x is a "work in progress".
> That's why it's marked "EXPERIMENTAL" in the Kconfig file.

It's not a work in progress, it works just fine for most people (the few 
that are left).

Last I heard, there was a problem with non-twisted-pair stuff, but 
that's about it.

'experimental' is generally a poorly maintained marker.

	Jeff


