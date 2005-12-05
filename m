From: Marc Singer <elf@buici.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 5 Dec 2005 13:03:29 -0800
Message-ID: <20051205210329.GC20824@buici.com>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com> <43948049.3040508@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Al Boldi <a1426z@gawab.com>, netdev@vger.kernel.org,
	linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <43948049.3040508@candelatech.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2005 at 10:00:41AM -0800, Ben Greear wrote:
> >Precisely the case.  It should be the case that a box response to an
> >arp on *any* interface for *any* IP address known to the box.
> 
> I certainly don't mind if this is a configurable, or even default
> behaviour, but we also need the ability to only respond to particular
> arps on particular interfaces, based on the IP addresses assigned
> to those interfaces.

Why?  The routing determines connectivity, not ARP.  AFAIK, ARP
requests are not made on interfaces that lack that the network being
queried.

If I put a host with an address on network 12 onto an ethernet segment
for network 10 and then ARP for addresses on network 10, I ought to be
able to send packets to those hosts (baring a firewal).  However, I
won't be able to get anything back because those hosts don't know how
to send to network 12.  Misconfiguration?  Yes.  Non-compliant?  No.

> I am able to get this particular arp binding working today, so I'm
> not suggesting changes, just mentioning that there are other
> configurations than what you mention that are useful to people.

Anyway, I haven't seen a good reason to change the current behavior.
While the above described functionality is missing, no one has made a
case to support it.
