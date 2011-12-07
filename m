From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC] iproute2: split up ip man page?
Date: Wed, 7 Dec 2011 21:46:38 +0000
Message-ID: <1323294398.2728.38.camel@bwh-desktop>
References: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:52726 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758042Ab1LGVqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2011 16:46:42 -0500
In-Reply-To: <20111207131514.6815f813@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-12-07 at 13:15 -0800, Stephen Hemminger wrote:
> The current ip man page is both incomplete and so big that
> the actual functions get lost easily.
> 
> I propose splitting the the pages for the subfunction
> into sub pages. The man command appears
> to be smart enough to handle:
>   man tc htb

Or, for another familiar example, 'man git diff'.

Oddly enough, man(1) only describes this under the '--no-subpages'
option which turns off the behaviour.

> and pickup the manpage for /usr/share/man/man1/tc-htb.8.gz
> Why not do the same thing for ip command?
> 
> The base ip page would just be a place holder that covered the
> generic arguments.

Sounds like a very sensible change.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
