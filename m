From: David Miller <davem@davemloft.net>
Subject: Re: Web10g TCP statistics patch - mainlining into kernel?
Date: Tue, 29 Jan 2013 13:52:22 -0500 (EST)
Message-ID: <20130129.135222.864358079580838703.davem@davemloft.net>
References: <18855.1359138716@turing-police.cc.vt.edu>
	<1359481755.4144.4.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Valdis.Kletnieks@vt.edu, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, web10g-user@web10g.org
To: bhutchings@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1359481755.4144.4.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 29 Jan 2013 17:49:15 +0000

> On Fri, 2013-01-25 at 13:31 -0500, Valdis Kletnieks wrote:
> [...]
>> it's a zero-hit thing for people who don't choose to configure
>> it into their kernel.
> [...]
> 
> People with high-overhead changes always say this, but before long
> distributions will be expected to enable it and then everyone pays the
> price.  So I think you'll have to work on limiting the run-time overhead
> when it's enabled at compile time but the user doesn't care about it.
> Possibly it can be a run-time option?  (I haven't looked at the code and
> don't expect to have time to do so.)

+1

The run time overhead must be zero when the feature is configured into
the kernel, and this requirement is non-negotiable.
