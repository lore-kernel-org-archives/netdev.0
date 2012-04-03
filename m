From: Thomas Graf <tgraf@infradead.org>
Subject: Re: netlink: 12 bytes leftover after parsing attributes - triggered
 by iproute2 libnetlink's rtnl_dump_request()
Date: Tue, 3 Apr 2012 06:01:57 -0400
Message-ID: <20120403100157.GA8611@canuck.infradead.org>
References: <20120320134107.6acea83c@pluto.restena.lu>
 <20120320074140.39a1b3f0@nehalam.linuxnetplumber.net>
 <1332255630.8043.11.camel@deadeye>
 <20120320170229.49de95f5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <ben@decadent.org.uk>,
	Bruno =?iso-8859-1?Q?Pr=E9mont?= <bonbons@linux-vserver.org>,
	netdev@vger.kernel.org, Greg Rose <gregory.v.rose@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:35647 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751290Ab2DCKCF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 06:02:05 -0400
Content-Disposition: inline
In-Reply-To: <20120320170229.49de95f5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 20, 2012 at 05:02:29PM -0700, Stephen Hemminger wrote:
> On Tue, 20 Mar 2012 15:00:30 +0000
> Ben Hutchings <ben@decadent.org.uk> wrote:
> 
> > On Tue, 2012-03-20 at 07:41 -0700, Stephen Hemminger wrote:
> > > 
> > > > 
> > > > Should this get fixed at kernel level, iproute2 libnetlink level or
> > > > at end-user level (e.g. collectd)?
> > > > Three lines every 10 seconds is a damn lot!
> > > > 
> > > > Thanks,
> > > > Bruno
> > > 
> > > Netlink is supposed to be encoded as Type-Length-Value and correctly written
> > > programs ignore types they don't understand. So either the library is getting
> > > confused by the type or the attribute is not encoded correctly.
> > > 
> > > 
> > > The issue could be in libnetlink library. What version of collectd and libnetlink
> > > are you using?
> > 
> > This was also reported as provoked by a client using the ntrack
> > rtnetlink code: http://thread.gmane.org/gmane.linux.network/224236

Bruno,

Can you send a full bug report to libnl@lists.infradead.org and I'll make sure
this gets addressed in libnl.
