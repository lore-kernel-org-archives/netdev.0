From: Mark Brown <broonie@opensource.wolfsonmicro.com>
Subject: Re: [RFC PATCH] Ethtool style in kernel network driver
	configuration.
Date: Fri, 12 Jun 2009 13:24:32 +0100
Message-ID: <20090612122431.GA8861@rakim.wolfsonmicro.main>
References: <ba4215e10906111045yf7288fbt4495d4dc96217d65@mail.gmail.com> <20090611.170948.66762524.davem@davemloft.net> <20090612105019.GA21599@sirena.org.uk> <20090612.043350.38954875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mfuzzey@gmail.com, bhutchings@solarflare.com, nico@cam.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from opensource.wolfsonmicro.com ([80.75.67.52]:33078 "EHLO
	opensource2.wolfsonmicro.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750749AbZFLMYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 08:24:31 -0400
Content-Disposition: inline
In-Reply-To: <20090612.043350.38954875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 12, 2009 at 04:33:50AM -0700, David Miller wrote:
> From: Mark Brown <broonie@opensource.wolfsonmicro.com>

> > How would you handle PCI devices in that scheme?  Last time I looked at
> > this (a while ago, so I may be out of date) there didn't appear to be a
> > sensible generic way of getting platform data to PCI devices.

> It's irrelevant in this discussion because in the contexts where
> this is wanted, people are adding driver-wide hacks to make
> these settings.

...which work well enough locally have problems getting upstream.

> For PCI, in general, the VPD or openfirmware descriptions could
> be used to describe such issues.

Where this is needed for PCI devices the VPD isn't useful - the hardware
often won't have the SEPROM (or whatever) that the device is intended to
load configuration from for cost or production reasons, the data being
provided elsewhere through something like OpenFirmware.

OpenFirmware works well enough on the platforms that use it but it's far
from universal.
