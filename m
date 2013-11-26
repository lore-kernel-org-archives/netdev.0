From: Ben Pfaff <blp@nicira.com>
Subject: Re: [ovs-dev] [PATCH v2.51 0/5] MPLS actions and matches
Date: Tue, 26 Nov 2013 07:33:47 -0800
Message-ID: <20131126153347.GA2662@nicira.com>
References: <1385005606-30130-1-git-send-email-horms@verge.net.au>
 <20131126080759.GA26597@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Ravi K <rkerur@gmail.com>
To: Simon Horman <horms@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog133.obsmtp.com ([74.125.149.82]:34318 "HELO
	na3sys009aog133.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756518Ab3KZPdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 10:33:53 -0500
Received: by mail-pb0-f51.google.com with SMTP id up15so8198937pbc.38
        for <netdev@vger.kernel.org>; Tue, 26 Nov 2013 07:33:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131126080759.GA26597@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 26, 2013 at 05:08:04PM +0900, Simon Horman wrote:
> On Thu, Nov 21, 2013 at 12:46:41PM +0900, Simon Horman wrote:
> > Hi,
> > 
> > This series implements MPLS actions and matches based on work by
> > Ravi K, Leo Alterman, Yamahata-san and Joe Stringer.
> > 
> > This series provides three changes
> > 
> > * Patches 1 - 3
> > 
> >   Provide user-space support for the VLAN/MPLS tag insertion order
> >   up to and including OpenFlow 1.2, and the different ordering
> >   specified from OpenFlow 1.3. In a nutshell the datapath always
> >   uses the OpenFlow 1.3 ordering, which is to always insert tags
> >   immediately after the L2 header, regardless of the presence of other
> >   tags. And ovs-vswtichd provides compatibility for the behaviour up
> >   to OpenFlow 1.2, which is that MPLS tags should follow VLAN tags
> >   if present.
> > 
> >   Ben, these are for you to review.
> 
> Hi Ben,
> 
> I wonder if you could find some time to look over these.
> 
> I believe that the first patch has not previously been reviewed
> but other than that there should be few areas of excitement.

I'm taking today and the remainder of this week off (Thursday and Friday
are a holiday here in the U.S.), so unfortunately there is not much
chance of progress before Monday.
