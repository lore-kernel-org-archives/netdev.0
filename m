From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: bond_compute_features() does not handle devices with different
 CSUM
Date: Wed, 30 May 2007 10:19:07 -0700
Message-ID: <20070530101907.28a131ab@freepuppy>
References: <97949e3e0705291741t4c485d38ud48b06e6d07e31bc@mail.gmail.com>
	<20070530092757.3417fb52@freepuppy>
	<97949e3e0705300958u1e162f14k3abdca2d8663c4b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Laurent Chavey" <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:58047 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757355AbXE3Raa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 13:30:30 -0400
In-Reply-To: <97949e3e0705300958u1e162f14k3abdca2d8663c4b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 30 May 2007 09:58:38 -0700
"Laurent Chavey" <chavey@google.com> wrote:

> should we then move/integrate that code as part of the bonding driver ?
> 
> 
> On 5/30/07, Stephen Hemminger <shemminger@linux-foundation.org> wrote:
> > On Tue, 29 May 2007 17:41:45 -0700
> > "Laurent Chavey" <chavey@google.com> wrote:
> >
> > > kernel version <= 2.6.20.1
> > > file drivers/net/bonding/bonding_main.c
> > > function bond_compute_features()
> > >
> > > -----------
> > >   Given a system with two different NIC. One driver sets
> > >         dev->features |=  NETIF_F_HW_CSUM
> > >   the other driver sets
> > >         dev->features |=  NETIF_F_IP_CSUM
> > >
> > >   when enslaving the 2 device above, bond_compute_features()
> > >   does not set the intersection of the 2 CSUM
> > >   features (should be NETIF_F_IP_CSUM)
> > > -----------
> > >
> > >    should the bond features in the case above include NETIF_F_IP_CSUM
> > > -
> > > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> > The bridge code already has a more complete/complex recompute
> > routine to handle this.
> >
> > --
> > Stephen Hemminger <shemminger@linux-foundation.org>
> >

Sure, that would be easier for maintenance.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
