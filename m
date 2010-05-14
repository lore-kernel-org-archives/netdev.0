From: Chris Wright <chrisw@redhat.com>
Subject: Re: [net-next-2.6 V7 PATCH 1/2] Add netlink support for virtual port
 management (was iovnl)
Date: Fri, 14 May 2010 11:25:26 -0700
Message-ID: <20100514182526.GO5798@x200.localdomain>
References: <C812DA73.31839%scofeldm@cisco.com>
 <4BED91D0.5020407@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <scofeldm@cisco.com>, Arnd Bergmann <arnd@arndb.de>,
	davem@davemloft.net, netdev@vger.kernel.org, chrisw@redhat.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58753 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751191Ab0ENSZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 14:25:34 -0400
Content-Disposition: inline
In-Reply-To: <4BED91D0.5020407@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Patrick McHardy (kaber@trash.net) wrote:
> Scott Feldman wrote:
> > On 5/14/10 10:29 AM, "Arnd Bergmann" <arnd@arndb.de> wrote:
> > 
> >> I was thinking that a device could have both IFLA_VF_PORTS and IFLA_PORT_SELF,
> >> but you know more about the IOV specifics. If an adapter having multiple
> >> VFs always gets configured as VF 0 itself, that would be fine as well,
> >> otherwise
> >> we could have an extra argument to the two device driver callbacks to
> >> differentiate VF/SELF. As long as this does not impact the user ABI, we
> >> could do either.
> > 
> > I think you're right.  I should have said AND/OR.  I would rather not have
> > an extra argument to the driver callbacks.
> >   
> >>> I think we should redo the other IFLA_VF_xxx msgs in the same style.  I'm
> >>> not going to tackle that for IFLA_VF_PORTS patch, but it would be a good
> >>> followup patch.
> >> I fear it's too late for that now. While we have not yet released 2.6.34
> >> and 2.6.33 does not contain the broken message, it's extremely late in the
> >> stabilization phase of v2.6.34, so I doubt that there is still a chance for
> >> that at this point.
> > 
> > That's too bad.  I wish Patrick's objections were honored and then we
> > wouldn't have followed that broken model!  Can the broken msgs be disabled
> > somehow for 2.6.34?  Keep the definitions in if_link.h but fail the SET/GET
> > actions in rtnetlink.c?
> 
> That would be a possibility. Unfortunately I don't think we can fix
> this in a backwards compatible way.

$ git describe --contains ebc08a6f47ee76ecad8e9f26c26e6ec9b46ca659
v2.6.34-rc1~233^2~336

It's not released yet?
