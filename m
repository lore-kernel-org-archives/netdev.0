From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 09:40:10 +0200
Message-ID: <20140423094010.17d2d763@endymion.delvare>
References: <20140414153849.7138699b@endymion.delvare>
	<20140422203209.GH12304@sirena.org.uk>
	<535768E1.8050609@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@kernel.org>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:55449 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751924AbaDWHkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 03:40:13 -0400
In-Reply-To: <535768E1.8050609@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Mark, Michal,

On Wed, 23 Apr 2014 09:16:49 +0200, Michal Simek wrote:
> On 04/22/2014 10:32 PM, Mark Brown wrote:
> > On Mon, Apr 14, 2014 at 03:38:49PM +0200, Jean Delvare wrote:
> >> The Cadence ethernet chipsets are only used on specific ARM
> >> architectures. Add Kconfig dependencies so that drivers for these
> >> chipsets are only buildable on the relevant architectures.
> > 
> > Are you sure they're not used on any of the FPGA platforms like
> > Microblaze?

I'm not sure of anything, embedded isn't my area.

> > Cadence are an IP company,

I can't parse this, sorry. What is an "IP company"?

> > might be worth having a FPGA
> > Kconfig that architectures commonly deployed with lots of soft IPs can
> > select and the IPs depend on rather than building a custom list for each
> > IP.

What are "soft IPs"? I'm afraid I wouldn't be able to translate your
proposal into a patch, I just don't understand what you mean exactly.

> macb driver can be used by Microblaze too.

Thanks for the information. I will send a patch adding MICROBLAZE to
the dependencies. Out of curiosity, is there any way I could have found
out by myself?

-- 
Jean Delvare
SUSE L3 Support
