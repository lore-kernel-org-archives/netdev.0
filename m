From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 12:48:38 +0200
Message-ID: <20140423124838.37aa0759@endymion.delvare>
References: <20140414153849.7138699b@endymion.delvare>
	<20140422203209.GH12304@sirena.org.uk>
	<535768E1.8050609@monstr.eu>
	<20140423094010.17d2d763@endymion.delvare>
	<5357897B.6020105@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@kernel.org>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:59030 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752517AbaDWKsm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 06:48:42 -0400
In-Reply-To: <5357897B.6020105@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

On Wed, 23 Apr 2014 11:35:55 +0200, Michal Simek wrote:
> On 04/23/2014 09:40 AM, Jean Delvare wrote:
> > Thanks for the information. I will send a patch adding MICROBLAZE to
> > the dependencies. Out of curiosity, is there any way I could have found
> > out by myself?
> 
> Microblaze doesn't need to be only one. I am not sure if there is
> any AXI bridge for openrisc.

You lost me here again :-(

> IMHO you should just add COMPILE_TEST and do not try to extend that
> list of dependencies.

COMPILE_TEST is already present, I can't add it twice ;-) But
COMPILE_TEST isn't supposed to be used when the architecture /
platform / system is actually expected to possibly need the driver in
question. If the list of possible hardware dependencies isn't well
known, or is too complex to express, or too difficult to maintain, then
we have to either make it broader, or even drop it.

Originally I wanted to hide the Cadence drivers from X86 kernel
configuration. If there's still a way to achieve that, let's do it. If
not, we can leave the hardware dependency for ARM_AT91_ETHER and drop
the one for MACB (and subsequently NET_CADENCE.) That's still better
than nothing.

Please let me know how you want to proceed.

Thanks,
-- 
Jean Delvare
SUSE L3 Support
