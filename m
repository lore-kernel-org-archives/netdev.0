From: Faidon Liambotis <faidon@cube.gr>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Mon, 12 Jun 2006 18:39:58 +0300
Message-ID: <20060612153958.GA6719@divinity>
References: <20060610175010.GA4617@divinity> <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com> <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity> <20060612152434.GA14851@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org,
	proski@gnu.org, hermes@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from linux7.grserver.gr ([64.34.170.238]:34213 "EHLO
	linux7.grserver.gr") by vger.kernel.org with ESMTP id S1752143AbWFLSnG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Jun 2006 14:43:06 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060612152434.GA14851@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 12, 2006 at 11:24:39AM -0400, John W. Linville wrote:
> On Mon, Jun 12, 2006 at 01:49:54AM +0300, Faidon Liambotis wrote:
> 
> > Having two drivers supporting the same set of hardware seems pretty
> > pointless to me. Plus, it confuses hotplugging/automatic detection.
> 
> This subject comes-up from time to time.  In fact, I'm pretty sure
> it came-up very recently w.r.t. orinoco and hostap.
I remember a patch that added all of Orinoco PCI IDs to HostAP. I'm not
sure if you're referring to that, but that's pretty different (and
obviously wrong).

> The consensus seems to be that drivers should have IDs for all devices
> they support, even if that means that some devices are supported by
> multiple drivers.  This leaves the choice of which driver to use in
> the hands of the user and/or distro.
I'd mostly agree to that if distributors had a way to enable/disable
Prism2 support on the orinoco_cs driver based on a build-time
configuration option.
Should I prepare such a patch?

FWIW, I think we've experienced a similar situation like this in the
past in the networking land and the consensus was to completely remove
the other driver. I'm referring to e100/eepro100, of course.

Regards,
Faidon
