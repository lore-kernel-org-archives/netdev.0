From: Jean Delvare <jdelvare@suse.de>
Subject: Re: [PATCH v2] net: cadence: Add architecture dependencies
Date: Wed, 23 Apr 2014 15:27:10 +0200
Message-ID: <20140423152710.4e6b7b9c@endymion.delvare>
References: <20140414153849.7138699b@endymion.delvare>
	<20140422203209.GH12304@sirena.org.uk>
	<535768E1.8050609@monstr.eu>
	<20140423094010.17d2d763@endymion.delvare>
	<5357897B.6020105@monstr.eu>
	<20140423124838.37aa0759@endymion.delvare>
	<5357A0A1.1020600@monstr.eu>
	<20140423113402.GV12304@sirena.org.uk>
	<5357BD14.1000608@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@kernel.org>, netdev@vger.kernel.org,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Fengguang Wu <fengguang.wu@intel.com>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33722 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752171AbaDWN1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 09:27:14 -0400
In-Reply-To: <5357BD14.1000608@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

On Wed, 23 Apr 2014 15:16:04 +0200, Michal Simek wrote:
> On 04/23/2014 01:34 PM, Mark Brown wrote:
> > On Wed, Apr 23, 2014 at 01:14:41PM +0200, Michal Simek wrote:
> >> Any reason to hide this driver for x86?
> > 
> > Distro maintainers like Jean are complaining about build times for their
> > kernels if they enable absolutely everything so if they're never likely
> > to see any hardware using something they want to skip it.

Exactly. See this discussion thread for details:
  https://lkml.org/lkml/2014/4/14/280

> Is there any reasonable solution for this?
> 1. One group is saying use COMPILE_TEST for every driver to have better
> coverage.

I think pretty much everyone agrees with this. The problem is that
COMPILE_TEST is relatively new so a lot of old drivers don't have it
yet, and developers and maintainers are not yet used to using it or
asking for it.

> 2. Next group is saying I don't want to build everything for my arch.

I don't understand what you mean here.

The idea is that distro maintainers or simple users don't set
COMPILE_TEST so they only see what is useful to them, while developers
set COMPILE_TEST to be able to build-test everything.

Before COMPILE_TEST was introduced, it wasn't possible to make everyone
happy. Now it is, so let's just do it.

> Fixing Kconfig to say !x86 is probably not the right way to go.

Definitely not. I did not even consider it as an acceptable workaround.
If we can't come up with reasonable dependencies for a given driver, we
can just leave it as is. There's plenty of easier drivers to work on :)

> Isn't it enough not to enable absolutely everything?

Everything that is visible requires everyone around to make a decision.
The more we can help them, the easier the process.

-- 
Jean Delvare
SUSE L3 Support
