From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: ethtool TODO list - additional info
Date: Tue, 12 Jul 2016 14:12:52 -0400
Message-ID: <20160712181251.GA22464@tuxdriver.com>
References: <CAPfrtUew6TKRMhoBfQ6MjxrCOsiQTYmM-2b20961LyRcLMOSZw@mail.gmail.com>
 <20160712175558.GB1799@nanopsycho.orion>
 <CAPfrtUcAuu5t7xQ-F4d-+AAbSByOzD7aBa_+UsE_xoXRdxEuoA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Ben Hutchings <ben@decadent.org.uk>,
	netdev <netdev@vger.kernel.org>
To: Jorge Alberto Garcia <jorge.garcia.gonzalez@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39130 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbcGLSPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 14:15:15 -0400
Content-Disposition: inline
In-Reply-To: <CAPfrtUcAuu5t7xQ-F4d-+AAbSByOzD7aBa_+UsE_xoXRdxEuoA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2016 at 01:04:52PM -0500, Jorge Alberto Garcia wrote:
> On Tue, Jul 12, 2016 at 12:55 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> > Tue, Jul 05, 2016 at 05:37:42PM CEST, jorge.garcia.gonzalez@gmail.com wrote:
> >>Hi !
> >>
> >>Some days ago, Jiri Pirko was talking about some next steps to
> >>implement for ethtool.
> >>
> >> I haven't seen any follow up since ethtool's maintainer change. Can we have
> >>additional details about these ?
> >>
> >>- libethtool - API
> >>- generic netlink
> >
> > Yep, exactly, no reply. Apparently nobody really want to do any initiative
> > here, and I'm lacking time to do it :(
> >
> 
> That's fine,  I already got  a git repo, I'm trying to understand what
> 'use generic netlink' means.
> 
> This is a piece of what grep got me on iproute git repo (I'm still
> trying to understand)
> grep -i netlink -r iproute2/
> iproute2/bridge/mdb.c:#include "libnetlink.h"
> iproute2/bridge/vlan.c:#include "libnetlink.h"
> ...
> ..

The general notion would be to replace the current ioctl-based
ethtool API with one that is based on netlink, like many of the other
networking APIs. I'm fine with the general idea of that, but so far
I haven't heard a strong case for why it is necessary. It certainly
doesn't seem urgent to me -- if someone disagrees, then please explain!

John

> >
> >
> >>- sub commands syntax
> >>- TODO/bugzilla
> >>
> >>
> >>On Mon, Jul 4, 2016 at 9:24 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> >>
> >>>>> I was thinking of adding a TODO file to the repository, but it's really
> >>>>> for the new maintainer to decide what to do.  So here's my list as a
> >>>>> suggestion:
> >>>>>
> >>>>> * Add regression test coverage for all sub-commands with complex logic
> >>>>>
> >>>>> * Internationalise output and error messages
> >>>>>
> >>>>> * Build a libethtool that handles all the API quirks and fallbacks for
> >>>>>   old kernel versions.  This might help people writing language
> >>>>>   bindings or other utilities that use the ethtool API.
> >>>>>
> >>>>> * Provide a 'cleaned up' ethtool (under some other name) that has:
> >>>>>   - More conventional sub-command syntax, i.e. no '-'/'--' prefix
> >>>>>   - More consistent output formatting
> >>>>
> >>>>That seems like a reasonable start for a TODO list. I'll bet there
> >>>>are a few people out there with other suggestions as well...?
> >>>
> >>> Before that, I would like to see ethtool migrate to use generic
> >>> netlink. Then, the new tool would be needed anyway, should exist within
> >>> iproute2 package and have similar command line syntax.
> >>>
> >>> I have some ideas about the gennetlink ethtool, have to find some time
> >>> to implement some initial part of it.
> 

-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
