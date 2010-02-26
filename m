From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [ethtool PATCH] ethtool: Support n-tuple filter programming
Date: Thu, 25 Feb 2010 22:09:07 -0800
Message-ID: <1267164547.2942.2.camel@localhost>
References: <4B85F173.40703@garzik.org>
	 <Pine.WNT.4.64.1002251739130.51452@ppwaskie-MOBL2.amr.corp.intel.com>
	 <4B87315E.4080905@garzik.org>
	 <20100225.215357.140469725.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "jeff@garzik.org" <jeff@garzik.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60301 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935271Ab0BZGJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Feb 2010 01:09:09 -0500
In-Reply-To: <20100225.215357.140469725.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-02-25 at 21:53 -0800, David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Thu, 25 Feb 2010 21:26:38 -0500
> 
> > On 02/25/2010 08:49 PM, Waskiewicz Jr, Peter P wrote:
> >> This will require a small kernel change.  Will something like this be
> >> pulled in at this point, given that 2.6.33 just released?
> > 
> > The n-tuple stuff is not in 2.6.33's ethtool interface, so it hasn't
> > actually made it into a released kernel at this point.
> > 
> > It seems reasonable for 2.6.34 to either add ETHTOOL_GSTRINGS_COUNT or
> > update drvinfo.  Even if net-next has already been pulled into
> > post-2.6.33 merge window, that would IMO qualify as a reasonable
> > interface bugfix to get upstream.  The ethtool n-tuple ABI is not
> > locked into stone until 2.6.34 is released by Linus.
> 
> Right.

Sounds good.  I wanted to make sure before I changed the ethtool bits.
Expect a patch for both the kernel side and userspace side shortly.

-PJ

