From: Simon Horman <horms@verge.net.au>
Subject: Re: [ovs-dev] [PATCH v2.51 0/5] MPLS actions and matches
Date: Wed, 27 Nov 2013 09:12:30 +0900
Message-ID: <20131127001230.GB5192@verge.net.au>
References: <1385005606-30130-1-git-send-email-horms@verge.net.au>
 <20131126080759.GA26597@verge.net.au>
 <20131126153347.GA2662@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Ravi K <rkerur@gmail.com>
To: Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51919 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751285Ab3K0AMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 19:12:35 -0500
Content-Disposition: inline
In-Reply-To: <20131126153347.GA2662@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 26, 2013 at 07:33:47AM -0800, Ben Pfaff wrote:
> On Tue, Nov 26, 2013 at 05:08:04PM +0900, Simon Horman wrote:
> > On Thu, Nov 21, 2013 at 12:46:41PM +0900, Simon Horman wrote:
> > > Hi,
> > > 
> > > This series implements MPLS actions and matches based on work by
> > > Ravi K, Leo Alterman, Yamahata-san and Joe Stringer.
> > > 
> > > This series provides three changes
> > > 
> > > * Patches 1 - 3
> > > 
> > >   Provide user-space support for the VLAN/MPLS tag insertion order
> > >   up to and including OpenFlow 1.2, and the different ordering
> > >   specified from OpenFlow 1.3. In a nutshell the datapath always
> > >   uses the OpenFlow 1.3 ordering, which is to always insert tags
> > >   immediately after the L2 header, regardless of the presence of other
> > >   tags. And ovs-vswtichd provides compatibility for the behaviour up
> > >   to OpenFlow 1.2, which is that MPLS tags should follow VLAN tags
> > >   if present.
> > > 
> > >   Ben, these are for you to review.
> > 
> > Hi Ben,
> > 
> > I wonder if you could find some time to look over these.
> > 
> > I believe that the first patch has not previously been reviewed
> > but other than that there should be few areas of excitement.
> 
> I'm taking today and the remainder of this week off (Thursday and Friday
> are a holiday here in the U.S.), so unfortunately there is not much
> chance of progress before Monday.

Enjoy your break :)
