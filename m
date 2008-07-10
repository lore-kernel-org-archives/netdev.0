From: Bill Nottingham <notting@redhat.com>
Subject: Re: [RFC PATCH 0/2] Allow full bridge configuration via sysfs
Date: Wed, 9 Jul 2008 22:34:29 -0400
Message-ID: <20080710023429.GB24665@nostromo.devel.redhat.com>
References: <20080707205342.GA19710@nostromo.devel.redhat.com> <4872838B.1060603@trash.net> <20080707213420.GA20089@nostromo.devel.redhat.com> <20080707.145259.103902820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750985AbYGJCfb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2008 22:35:31 -0400
Content-Disposition: inline
In-Reply-To: <20080707.145259.103902820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller (davem@davemloft.net) said: 
> > Why, if netlink is the standard (and it's been around for a long
> > damn time), was sysfs configuration for bonding added in 2005? Why
> > was bridge configuration added in 2005, and *extended* in 2006 and
> > 2007? Why were the user-space tools such as brctl ported from ioctl
> > to sysfs?
> 
> Because often a lot of shit slips in when someone who understands
> the ramifications is too busy or on vacation.

Duly noted, will time all patch submissions to land during your
vacations in the future.

More seriously, if there's not a mechanism to prevent ABIs the
kernel doesn't want like this being added, that's a problem.

> We do want everything to be netlink based.
> 
> Why?
> 
> Because it means that you can run one monitoring tool to listen
> for netlink events and report them to the user for diagnosis.
> 
> It means that network configuration events can be sent over
> the wire and used remotely at some point.
> 
> The latter can never happen as long as we keep adding ad-hoc
> config stuff.

Sure, but it does make them more opaque to the normal user,
leaving them wrapped in the same old ip/brctl/ifenslave/vconfig
tools - for better or worse, people like the discoverability
and obviousness of sysfs.

Bill
