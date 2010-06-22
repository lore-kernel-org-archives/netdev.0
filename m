From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Tue, 22 Jun 2010 12:45:45 +0100
Message-ID: <1277207145.2091.3.camel@achroite.uk.solarflarecom.com>
References: <20100204075101.16661.95658.stgit@localhost.localdomain>
	 <1277150272.2100.47.camel@achroite.uk.solarflarecom.com>
	 <Pine.WNT.4.64.1006211326380.4956@PPWASKIE-MOBL2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:30424 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562Ab0FVLpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 07:45:49 -0400
In-Reply-To: <Pine.WNT.4.64.1006211326380.4956@PPWASKIE-MOBL2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-06-21 at 13:31 -0700, Peter P Waskiewicz Jr wrote:
> On Mon, 21 Jun 2010, Ben Hutchings wrote:
> 
> > On Wed, 2010-02-03 at 23:51 -0800, Jeff Kirsher wrote:
> >> From: Peter Waskiewicz <peter.p.waskiewicz.jr@intel.com>
> >>
> >> Program underlying ethernet devices with n-tuple flow classification
> >> filters.
> >>
> >> This also adds a new flag to ethtool_flags, allowing n-tuple
> >> programming to be toggled using the set_flags call.
> >
> > I just noticed a problem with the implementation which makes me wonder
> > whether this was tested at all:
> 
> Yes, it was tested.  We didn't hit every corner case, which I think your 
> catch below is a corner case issue.  Our hardware can only do so much.

It's not a corner case.  You have added options that cannot work
correctly.

[...]
> When this was proposed, we added the IPv4 address as a single int.  People 
> seemed ok with it at the time, so we went with it.  If you have a 
> different approach, please present it.

And you don't think it matters that the address has to be written
differently on big- and little-endian architectures?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

