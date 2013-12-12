From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 0/2] Display adjacent switch port's attributes
Date: Thu, 12 Dec 2013 22:00:51 +0000
Message-ID: <1386885651.1516.321.camel@bwh-desktop.uk.level5networks.com>
References: <1386768540-48188-1-git-send-email-raspl@linux.vnet.ibm.com>
	 <20131211121357.4742d9e8@nehalam.linuxnetplumber.net>
	 <52A9C0BE.5090801@linux.vnet.ibm.com>
	 <20131212.122801.1249371766101769652.davem@davemloft.net>
	 <52A9F7CD.5050904@intel.com>
	 <CAGVrzcb47oUAn-5S=DpQkgPbMAwmBrfjUmfJroYiYX8mmRuORg@mail.gmail.com>
	 <52AA2EF4.70300@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	<raspl@linux.vnet.ibm.com>, "David Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	<blaschka@linux.vnet.ibm.com>, netdev <netdev@vger.kernel.org>,
	<linux-s390@vger.kernel.org>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:6052 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751566Ab3LLWA4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 17:00:56 -0500
In-Reply-To: <52AA2EF4.70300@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-12 at 13:47 -0800, John Fastabend wrote:
> [...]
> 
> >> Just to elaborate...
> >>
> >> Any application using lldp information will want to get events when
> >> TLVs change. Maybe you can contrive ethtool to do this but its going to
> >> be ugly. Netlink can support multicast events and applications can
> >> register for them. Also netlink's TLV format matches nicely with LLDPs
> >> TLV format.
> >
> > ethtool and netlink usually intersect for a few bits of information
> > such as link status for instance. It is useful to have this
> > information twice, with ethtool as a debugging aid, and via netlink to
> > take appropriate actions.
> >
> > Maybe we just need to be clear on what needs to be present in ethtool
> > only (configuration, static information) and see on a case-by-case
> > what needs to be present in both ethtool and netlink?
> >
> 
> OK if there is an enable/disable bit in ethtool that might make some
> sense. Or an error flag that is helpful to have.
> 
> In this case we are dealing with peer attributes which are dynamic and
> in my opinion should go into netlink and duplicating them in ethtool
> although possible doesn't seem very useful to me.

I agree with this - rtnetlink seems to make more sense.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
