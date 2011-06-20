From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] Moving files around in drivers/net
Date: Mon, 20 Jun 2011 04:22:12 +0100
Message-ID: <1308540132.11457.97.camel@localhost>
References: <1306956602.32125.28.camel@Joe-Laptop>
	 <1306957998.3076.18.camel@jtkirshe-MOBL1>
	 <1306958478.32125.32.camel@Joe-Laptop>
	 <BANLkTi=BAqKzZeLF2_uCYnr7PD3StGFgAg@mail.gmail.com>
	 <1308186619.12377.23.camel@Joe-Laptop>
	 <1308536729.22851.42.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joe Perches <joe@perches.com>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Jan Engelhardt <jengelh@medozas.de>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8744 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752458Ab1FTDWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 23:22:16 -0400
In-Reply-To: <1308536729.22851.42.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-06-19 at 19:25 -0700, Jeff Kirsher wrote:
> On Wed, 2011-06-15 at 18:10 -0700, Joe Perches wrote:
[...]
> > Some manufacturer directories are directly populated
> > with multiple drivers, some have subdirectories.
> > Should one style be consistently used?
> 
> This is a grey area.  I think it makes more sense to group drivers
> either by company, maintainer, bus or commonly used header.  It has been
> expressed by others in the community and while placing drivers in
> driver/net/ethernet/<company name> is nice way to organize, companies
> get bought and sold and driver ownership moves from one company to
> another.  To constantly rename directories based on the ownership may
> cause un-necessary flux in the directory structure.  I tried to tried to
> avoid using company names unless I was confident about it.

You could try to futureproof by leaving out companies altogether and
just considering the technical heritage of hardware.  For example, the
netxen and qlcnic drivers appear to work with related hardware, but qlge
and qlcnic do not.  But this is possibly not a lot more objective than
what you've done so far, and it doesn't make it any easier to name the
directories.

> Some of the suggestions you listed below seem fine, especially since
> several of these companies have been around for some time and actively
> maintain their driver(s).
[...]
> > sfc may be solarflare
[...]

This directory only contains a single net driver, and its name matches
the prefix for Solarflare controller part numbers (not LOMs, but the
driver doesn't care about the distinction).  Any separate driver for
future Solarflare hardware is also likely to be named beginning with the
letters 'sfc'.  So I'd be happier if this was *not* renamed.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

