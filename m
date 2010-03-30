From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: XT_ALIGN changed to use ALIGN breaks iproute2
Date: Tue, 30 Mar 2010 08:29:02 -0700
Message-ID: <20100330082902.6d64d21d@nehalam>
References: <20100330092829.GA3106@amd64.fatal.se>
 <b6fcc0a1003300615k54092120nfb8b5378771657@mail.gmail.com>
 <1269961278.2174.11.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexey Dobriyan <adobriyan@gmail.com>,
	Andreas Henriksson <andreas@fatal.se>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55042 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297Ab0C3P3i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Mar 2010 11:29:38 -0400
In-Reply-To: <1269961278.2174.11.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 30 Mar 2010 16:01:18 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Tue, 2010-03-30 at 16:15 +0300, Alexey Dobriyan wrote:
> > On Tue, Mar 30, 2010 at 12:28 PM, Andreas Henriksson <andreas@fatal.se> wrote:
> > > You updated the kernel header include/linux/netfilter/x_tables.h
> > > in torvalds/linux-2.6.git commit 42107f5009da223daa800d6da6904d77297ae829
> > > with the comment "Use ALIGN() macro while I'm at it for same types.".
> > >
> > > When this header was synced into iproute2 the build broke because the
> > > ALIGN macro apparently only is defined in kernel headers.
> > >
> > > (For iproute2 the problem was introduced in
> > > 8ecdcce08319d0e39b0d32c1d17db3f69d85a35c and found by Stephen
> > > and worked around in 609ceb807deba8e23 and edaaa11e5a3cf2c9c1a39)
> > >
> > > I'm guessing the problem in the iproute2 header sync is just a heads
> > > up for what's going to happen when distributions updates their
> > > system headers to match linux 2.6.33.
> > >
> > >
> > > Could someone who knows how the userspace version of the kernel
> > > headers are generated please find a suitable solution?
> > 
> > We can export ALIGN to userspace, but the name is so generic,
> > so it's not clear what breakage more risky.
> 

I put a hack in m_xt.c to keep iproute2 building.
But this is a temporary workaround until you guys figure out the
right answer.

-- 
