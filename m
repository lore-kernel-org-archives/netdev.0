From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [patch 2.6.25-rc3] smc91x section fix
Date: Mon, 25 Feb 2008 21:11:12 +0100
Message-ID: <20080225201112.GA23667@uranus.ravnborg.org>
References: <20080225033411.941C328DEAA@adsl-69-226-248-13.dsl.pltn13.pacbell.net> <20080225060220.GA12459@uranus.ravnborg.org> <200802242233.12764.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nico@cam.org, netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpa.tele.dk ([80.160.77.114]:54399 "EHLO pasmtpA.tele.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755941AbYBYULA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Feb 2008 15:11:00 -0500
Content-Disposition: inline
In-Reply-To: <200802242233.12764.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 24, 2008 at 10:33:12PM -0800, David Brownell wrote:
> On Sunday 24 February 2008, Sam Ravnborg wrote:
> 
> > From a quick look this is wrong.
> > smc_drv_probe is assined the .probe member so it is used during
> > hotplug and thus should be __devinit.
> > Likewise smc_probe is used by smc_drv_probe and thus smc_probe
> > should be __devinit too.
> 
> Thing is, with only rare exceptions, devices on the platform
> bus are *NOT* hotpluggable.  So using __devinit/__devexit and
> friends adds up to no more than a waste of I-space.

It was a quick look - thanks for the explanation.

	Sam
