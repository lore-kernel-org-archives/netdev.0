From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH 2.6.17-rc6] Remove Prism II support from Orinoco
Date: Thu, 15 Jun 2006 00:45:13 -0400
Message-ID: <1150346713.26487.24.camel@dv>
References: <20060610175010.GA4617@divinity>
	 <20060610180850.GP7420@redhat.com> <20060611222719.GA13139@redhat.com>
	 <20060611224054.GB13139@redhat.com> <20060611224954.GA2880@divinity>
	 <20060612152434.GA14851@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Faidon Liambotis <faidon@cube.gr>, Dave Jones <davej@redhat.com>,
	netdev@vger.kernel.org, hermes@gibson.dropbear.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:22157 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1750798AbWFOEpV
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jun 2006 00:45:21 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FqjjL-0008FS-Cr
	for netdev@vger.kernel.org; Thu, 15 Jun 2006 00:45:19 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060612152434.GA14851@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, John!

On Mon, 2006-06-12 at 11:24 -0400, John W. Linville wrote:
> On Mon, Jun 12, 2006 at 01:49:54AM +0300, Faidon Liambotis wrote:
> 
> > Having two drivers supporting the same set of hardware seems pretty
> > pointless to me. Plus, it confuses hotplugging/automatic detection.
> 
> This subject comes-up from time to time.  In fact, I'm pretty sure
> it came-up very recently w.r.t. orinoco and hostap.
> 
> The consensus seems to be that drivers should have IDs for all devices
> they support, even if that means that some devices are supported by
> multiple drivers.  This leaves the choice of which driver to use in
> the hands of the user and/or distro.
> 
> If the Orinoco guys want this patch, I'll consider it.  Otherwise,
> I'm not inclined to take it.

I really appreciate your position in this regard.

The patch in question was never submitted to the orinoco mailing list.
I believe any such changes should be discussed by people using the
driver and participating in its development.  It's not some minor change
or API update.

I'm ready to consider disabling some ID's conditionally, primarily for
systems that cannot use udev.  But it's far from the top of my TODO
list.  And I'm not sure it would actually help users of desktop
distributions.

-- 
Regards,
Pavel Roskin

