From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 03/33] sfc: Do not use pci_disable_device() to disable bus mastering
Date: Sat, 13 Dec 2008 06:27:10 +0000
Message-ID: <20081213062708.GI10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com> <20081212124622.GK32518@solarflare.com> <20081212124913.GC10372@solarflare.com> <20081212.213108.52725498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:42704 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750745AbYLMG1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 01:27:12 -0500
Content-Disposition: inline
In-Reply-To: <20081212.213108.52725498.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Fri, 12 Dec 2008 12:49:14 +0000
> 
> > pci_disable_device() disables many features, like MSI-X, which we
> > never reenable in efx_reset().  Further, calls to pci_enable_device()
> > and pci_disable_device() must be matched since the nesting count was
> > introduced.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> 
> Since the PCI layer provides interfaces which do manage
> this setting, there is no way you should be doing this
> behind it's back.
> 
> You know why?
> 
> Because someone is going to change some of the internals
> of this stuff in the PIC layer and it will break your
> driver.
> 
> Please instead submit an interface to the PCI layer
> maintainers that does what you want, then use it.

I did ask on #linux-pci why this didn't exist; apparently it wasn't
considered to be worth providing.  So obviously I can submit a patch to
the PCI layer but I'm not sure it would be accepted.

Ben.

> Patch not applied.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
