From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: brcm80211 breakage..
Date: Wed, 11 Jan 2012 17:15:30 +0000
Message-ID: <1326302130.2705.3.camel@bwh-desktop>
References: <CA+55aFxw5e3EYCGYjkWiTmhy9-WaY4T_-MF7EYcn4jXuBoxAgw@mail.gmail.com>
	 <4F0D6806.4080201@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Network Development <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	=?UTF-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42595 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755320Ab2AKRPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2012 12:15:38 -0500
In-Reply-To: <4F0D6806.4080201@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-01-11 at 11:44 +0100, Arend van Spriel wrote:
> On 01/10/2012 09:15 PM, Linus Torvalds wrote:
> > So the wireless on my Macbook Air no longer seems to work with the
> > current -git tree.
> > 
> > The BRCMSMAC driver *used* to work, and no longer does. Also, very
> > annoyingly, it's even hard to *compile* the thing, because it used to
> > be
> > 
> >   depends on BCMA=n
> > 
> > but now it is the exact reverse:
> > 
> >   depends on BCMA
> > 
> > so there is no sane way to carry a configuration over from before, and
> > things like bisection is a major pain due to having to play idiotic
> > configuration games to get it to work across all these modifications.
> 
> BCMA support has been added to brcmsmac so now we depend on it. As BCMA
> claims the PCI device we had the BCMA=n in place before. I agree that it
> makes bisecting a pain in the...
[...]

Maybe BRCMSMAC should select BCMA rather than depending on it.  This bus
seems like kind of an implementation detail that people are unlikely to
be aware of, unlike say PCI.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
